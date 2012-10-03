
#import "PushNotificationPlugin.h"
#import "UAPush.h"
#import "UAirship.h"
#import "UAAnalytics.h"
#import "UAAppDelegateSurrogate.h"
#import "UALocationService.h"
#import "UA_SBJsonWriter.h"

typedef id (^UACordovaCallbackBlock)(NSArray *args);
typedef void (^UACordovaVoidCallbackBlock)(NSArray *args);

@interface PushNotificationPlugin()
- (void)takeOff;
@end

@implementation PushNotificationPlugin

- (id)initWithWebView:(UIWebView *)theWebView {
    if (self = [super initWithWebView:theWebView]) {
        [UAAppDelegateSurrogate shared].surrogateDelegate = self;
        [self takeOff];
    }
    return self;
}

- (void)takeOff {
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];

    // Analytics immplementation
    [takeOffOptions setValue:[NSNumber numberWithBool:YES] forKey:UAAnalyticsOptionsLoggingKey];

    [takeOffOptions setValue:[UAAppDelegateSurrogate shared].launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];

    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];

    [[UAPush shared] resetBadge];//zero badge on startup
}

- (void)failWithCallbackID:(NSString *)callbackID {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self writeJavascript: [result toErrorCallbackString:callbackID]];
}

- (void)succeedWithPluginResult:(CDVPluginResult *)result withCallbackID:(NSString *)callbackID {
    [self writeJavascript: [result toSuccessCallbackString:callbackID]];
}

- (BOOL)validateArguments:(NSArray *)args forExpectedTypes:(NSArray *)types {
    if (args.count == types.count) {
        for (int i = 0; i < args.count; i++) {
            if (![[args objectAtIndex:i] isKindOfClass:[types objectAtIndex:i]]) {
                //fail when when there is a type mismatch an expected and passed parameter
                UALOG(@"type mismatch in cordova callback: expected %@ and received %@", 
                      [types description], [args description]);
                return NO;
            }
        }
    } else {
        //fail when there is a number mismatch
        UALOG(@"parameter number mismatch in cordova callback: expected %d and received %d", types.count, args.count);
        return NO;
    }
    
    return YES;
}

- (CDVPluginResult *)pluginResultForValue:(id)value {
    CDVPluginResult *result;
    
    /*
     NSSString -> String
     NSNumber --> (Integer | Double)
     NSArray --> Array
     NSDictionary --> Object
     nil --> no return value
     */
    
    if ([value isKindOfClass:[NSString class]]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        CFNumberType numberType = CFNumberGetType((CFNumberRef)value);
        //note: underlyingly, BOOL values are typedefed as char
        if (numberType == kCFNumberIntType || numberType == kCFNumberCharType) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[value intValue]];
        } else  {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:[value doubleValue]];
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:value];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:value];
    } else if ([value isKindOfClass:[NSNull class]]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        UALOG(@"cordova callback block returned unrecognized type: %@", NSStringFromClass([value class]));
        return nil;
    }
    
    return result;
}

- (void)performCallbackWithArgs:(NSMutableArray *)args expecting:(NSArray *)expected withBlock:(UACordovaCallbackBlock)block {
    if (!args.count) {
        UALOG(@"cordova callback must contain at least a callbackID parameter, bailing");
        return;
    }
    //pop the callback ID off the array. we should now have the expected number of arguments
    id callbackID = [args pop];

    if (![callbackID isKindOfClass:[NSString class]]) {
        UALOG(@"cordova callback ID must be an NSString, bailing");
        return;
    }

    //if we're expecting any arguments
    if (expected) {
        if (![self validateArguments:args forExpectedTypes:expected]) {
            [self failWithCallbackID:callbackID];
            return;
        }
    } else if(args.count) {
        UALOG(@"paramter number mismatch: expected 0 and received %d", args.count);
        [self failWithCallbackID:callbackID];
        return;
    }

    //execute the block. the return value should be an obj-c object holding what we want to pass back to cordova.
    id returnValue = block(args);
    CDVPluginResult *result = [self pluginResultForValue:returnValue];
    if (result) {
        [self succeedWithPluginResult:result withCallbackID:callbackID];
    } else {
        [self failWithCallbackID:callbackID];
    }
}

- (void)performCallbackWithArgs:(NSMutableArray *)args expecting:(NSArray *)expected withVoidBlock:(UACordovaVoidCallbackBlock)block {
    [self performCallbackWithArgs:args expecting:expected withBlock:^(NSArray *args) {
        block(args);
        return [NSNull null];
    }];
}

- (NSString *)alertForUserInfo:(NSDictionary *)userInfo {
    NSString *alert = @"";

    if ([[userInfo allKeys] containsObject:@"aps"]) {
        NSDictionary *apsDict = [userInfo objectForKey:@"aps"];
        //TODO: what do we want to do in the case of a localized alert dictionary?
        if ([[apsDict valueForKey:@"alert"] isKindOfClass:[NSString class]]) {
            alert = [apsDict valueForKey:@"alert"];
        }
    }

    return alert;
}

- (NSMutableDictionary *)extrasForUserInfo:(NSDictionary *)userInfo {

    // remove extraneous key/value pairs
    NSMutableDictionary *extras = [NSMutableDictionary dictionaryWithDictionary:userInfo];

    if([[extras allKeys] containsObject:@"aps"]) {
        [extras removeObjectForKey:@"aps"];
    }
    if([[extras allKeys] containsObject:@"_uamid"]) {
        [extras removeObjectForKey:@"_uamid"];
    }
    if([[extras allKeys] containsObject:@"_"]) {
        [extras removeObjectForKey:@"_"];
    }

    return extras;
}

#pragma mark Phonegap bridge

//events

- (void)raisePush:(NSString *)message withExtras:(NSDictionary *)extras {

    if (!message || !extras) {
        UALOG(@"PushNotificationPlugin: attempted to raise push with nil message or extras");
        message = @"";
        extras = [NSMutableDictionary dictionary];
    }

    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    [data setObject:message forKey:@"message"];
    [data setObject:extras forKey:@"extras"];

    UA_SBJsonWriter *writer = [[[UA_SBJsonWriter alloc] init] autorelease];
    NSString *json = [writer stringWithObject:data];
    NSString *js = [NSString stringWithFormat:@"window.pushNotification.pushCallback(%@);", json];

    [self writeJavascript:js];

    UALOG(@"js callback: %@", js);
}

- (void)raiseRegistration:(BOOL)valid withpushID:(NSString *)pushID {

    if (!pushID) {
        UALOG(@"PushNotificationPlugin: attempted to raise registration with nil pushID");
        pushID = @"";
        valid = NO;
    }

    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSNumber numberWithBool:valid] forKey:@"valid"];
    [data setObject:pushID forKey:@"pushID"];

    UA_SBJsonWriter *writer = [[[UA_SBJsonWriter alloc] init] autorelease];
    NSString *json = [writer stringWithObject:data];
    NSString *js = [NSString stringWithFormat:@"window.pushNotification.registrationCallback(%@);", json];

    [self writeJavascript:js];

    UALOG(@"js callback: %@", js);
}

//registration

- (void)registerForNotificationTypes:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    UALOG(@"PushNotificationPlugin: register for notification types");
    NSString *callbackID = [args pop];

    if (args.count >= 1) {
        id obj = [args objectAtIndex:0];

        if ([obj isKindOfClass:[NSNumber class]]) {
            UIRemoteNotificationType bitmask = [obj intValue];
            UALOG(@"bitmask value: %d", [obj intValue]);
            [[UAPush shared] registerForRemoteNotificationTypes:bitmask];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self writeJavascript: [result toSuccessCallbackString:callbackID]];
        } else {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self writeJavascript: [result toErrorCallbackString:callbackID]];
        }

    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self writeJavascript: [result toErrorCallbackString:callbackID]];
    }
}

//general enablement

- (void)enablePush:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withVoidBlock:^(NSArray *args){
        [UAPush shared].pushEnabled = YES;
        //forces a reregistration
        [[UAPush shared] updateRegistration];
    }];
}

- (void)disablePush:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withVoidBlock:^(NSArray *args){
        [UAPush shared].pushEnabled = NO;
        //forces a reregistration
        [[UAPush shared] updateRegistration];
    }];
}

- (void)enableLocation:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withVoidBlock:^(NSArray *args){
        [UALocationService setAirshipLocationServiceEnabled:YES];
    }];
}

- (void)disableLocation:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withVoidBlock:^(NSArray *args){
        [UALocationService setAirshipLocationServiceEnabled:NO];
    }];
}

- (void)enableBackgroundLocation:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withVoidBlock:^(NSArray *args){
        [UAirship shared].locationService.backgroundLocationServiceEnabled = YES;
    }];
}

- (void)disableBackgroundLocation:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withVoidBlock:^(NSArray *args){
        [UAirship shared].locationService.backgroundLocationServiceEnabled = NO;
    }];
}

//getters

- (void)isPushEnabled:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        BOOL enabled = [UAPush shared].pushEnabled;
        return [NSNumber numberWithBool:enabled];
    }];
}

- (void)isQuietTimeEnabled:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        BOOL enabled = [UAPush shared].quietTimeEnabled;
        return [NSNumber numberWithBool:enabled];
    }];
}

- (void)isInQuietTime:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        BOOL inQuietTime;
        NSDictionary *quietTimeDictionary = [UAPush shared].quietTime;
        if (quietTimeDictionary) {
            NSString *start = [quietTimeDictionary valueForKey:@"start"];
            NSString *end = [quietTimeDictionary valueForKey:@"end"];

            NSDateFormatter *df = [[NSDateFormatter new] autorelease];
            df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
            df.dateFormat = @"HH:mm";

            NSDate *startDate = [df dateFromString:start];
            NSDate *endDate = [df dateFromString:end];

            NSDate *now = [NSDate date];

            inQuietTime = ([now earlierDate:startDate] == startDate && [now earlierDate:endDate] == now);
        } else {
            inQuietTime = NO;
        }

        return [NSNumber numberWithBool:inQuietTime];
    }];
}

- (void)isLocationEnabled:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        BOOL enabled = [UALocationService airshipLocationServiceEnabled];
        return [NSNumber numberWithBool:enabled];
    }];
}

- (void)isBackgroundLocationEnabled:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        BOOL enabled = [UAirship shared].locationService.backgroundLocationServiceEnabled;
        return [NSNumber numberWithBool:enabled];
    }];
}

- (void)getIncoming:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        NSString *incomingAlert = @"";
        NSMutableDictionary *incomingExtras = [NSMutableDictionary dictionary];

        NSDictionary *launchOptions = [UAAppDelegateSurrogate shared].launchOptions;
        if ([[launchOptions allKeys]containsObject:@"UIApplicationLaunchOptionsRemoteNotificationKey"]) {
            NSDictionary *payload = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
            incomingAlert = [self alertForUserInfo:payload];
            [incomingExtras setDictionary:[self extrasForUserInfo:payload]];
        }

        NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionary];

        [returnDictionary setObject:incomingAlert forKey:@"message"];
        [returnDictionary setObject:incomingExtras forKey:@"extras"];

        return returnDictionary;
    }];
}

- (void)getPushID:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        NSString *pushID = [UAirship shared].deviceToken ?: @"";
        return pushID;
    }];
}

- (void)getQuietTime:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        NSDictionary *quietTimeDictionary = [UAPush shared].quietTime;
        //initialize the returned dictionary with zero values
        NSNumber *zero = [NSNumber numberWithInt:0];
        NSDictionary *returnDictionary = [NSDictionary dictionaryWithObjectsAndKeys:zero,@"startHour",
                                          zero,@"startMinute",
                                          zero,@"endHour",
                                          zero,@"endMinute",nil];
        //this can be nil if quiet time is not set
        if (quietTimeDictionary) {

            NSString *start = [quietTimeDictionary objectForKey:@"start"];
            NSString *end = [quietTimeDictionary objectForKey:@"end"];

            NSDateFormatter *df = [[NSDateFormatter new] autorelease];
            df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
            df.dateFormat = @"HH:mm";

            NSDate *startDate = [df dateFromString:start];
            NSDate *endDate = [df dateFromString:end];

            //these will be nil if the dateformatter can't make sense of either string
            if (startDate && endDate) {

                NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];

                NSDateComponents *startComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:startDate];
                NSDateComponents *endComponents = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:endDate];

                NSNumber *startHr = [NSNumber numberWithInt:startComponents.hour];
                NSNumber *startMin = [NSNumber numberWithInt:startComponents.minute];
                NSNumber *endHr = [NSNumber numberWithInt:endComponents.hour];
                NSNumber *endMin = [NSNumber numberWithInt:endComponents.minute];

                returnDictionary = [NSDictionary dictionaryWithObjectsAndKeys:startHr,@"startHour",startMin,@"startMinute",
                                    endHr,@"endHour",endMin,@"endMinute",nil];
            }
        }
        return returnDictionary;
    }];
}

- (void)getTags:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        NSArray *tags = [UAPush shared].tags? : [NSArray array];
        NSDictionary *returnDictionary = [NSDictionary dictionaryWithObjectsAndKeys:tags, @"tags", nil];
        return returnDictionary;
    }];
}

- (void)getAlias:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withBlock:^(NSArray *args){
        NSString *alias = [UAPush shared].alias ?: @"";
        return alias;
    }];
}

//setters

- (void)setTags:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:[NSArray arrayWithObjects:[NSArray class],nil] withVoidBlock:^(NSArray *args) {
        NSMutableArray *tags = [NSMutableArray arrayWithArray:[args objectAtIndex:0]];
        [UAPush shared].tags = tags;
        [[UAPush shared] updateRegistration];
    }];
}

- (void)setAlias:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:[NSArray arrayWithObjects:[NSString class],nil] withVoidBlock:^(NSArray *args) {
        NSString *alias = [args objectAtIndex:0];
        [UAPush shared].alias = alias;
        [[UAPush shared] updateRegistration];
    }];
}

- (void)setQuietTimeEnabled:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:[NSArray arrayWithObjects:[NSNumber class],nil] withVoidBlock:^(NSArray *args) {
        NSNumber *value = [args objectAtIndex:0];
        BOOL enabled = [value boolValue];
        [UAPush shared].quietTimeEnabled = enabled;
        [[UAPush shared] updateRegistration];
    }];
}

- (void)setQuietTime:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    Class c = [NSNumber class];
    [self performCallbackWithArgs:args expecting:[NSArray arrayWithObjects:c,c,c,c,nil] withVoidBlock:^(NSArray *args) {
        id startHr = [args objectAtIndex:0];
        id startMin = [args objectAtIndex:1];
        id endHr = [args objectAtIndex:2];
        id endMin = [args objectAtIndex:3];

        NSDate *startDate;
        NSDate *endDate;

        NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *startComponents = [[[NSDateComponents alloc] init] autorelease];
        NSDateComponents *endComponents = [[[NSDateComponents alloc] init] autorelease];

        startComponents.hour = [startHr intValue];
        startComponents.minute =[startMin intValue];
        endComponents.hour = [endHr intValue];
        endComponents.minute = [endMin intValue];

        startDate = [gregorian dateFromComponents:startComponents];
        endDate = [gregorian dateFromComponents:endComponents];

        [[UAPush shared] setQuietTimeFrom:startDate to:endDate withTimeZone:[NSTimeZone localTimeZone]];
        [[UAPush shared] updateRegistration];        
    }];
}

- (void)setAutobadgeEnabled:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:[NSArray arrayWithObjects:[NSNumber class],nil] withVoidBlock:^(NSArray *args) {
        NSNumber *number = [args objectAtIndex:0];
        BOOL enabled = [number boolValue];
        [UAPush shared].autobadgeEnabled = enabled;
    }];
}

- (void)setBadgeNumber:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:[NSArray arrayWithObjects:[NSNumber class],nil] withVoidBlock:^(NSArray *args) {
        id number = [args objectAtIndex:0];
        NSInteger badgeNumber = [number intValue];
        [[UAPush shared] setBadgeNumber:badgeNumber];
    }];
}

//reset badge

- (void)resetBadge:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withVoidBlock:^(NSArray *args) {
        [[UAPush shared] resetBadge];
        [[UAPush shared] updateRegistration];
    }];
}

//location recording

- (void)recordCurrentLocation:(NSMutableArray *)args withDict:(NSMutableDictionary *)options {
    [self performCallbackWithArgs:args expecting:nil withVoidBlock:^(NSArray *args) {
        [[UAirship shared].locationService reportCurrentLocation];
    }];
}


#pragma mark UIApplicationDelegate callbacks

- (void)applicationWillTerminate:(UIApplication *)application {
     [UAirship land];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
     // Updates the device token and registers the token with UA
    UALOG(@"PushNotificationPlugin: registered for remote notifications");
    [[UAPush shared] registerDeviceToken:deviceToken];
    [self raiseRegistration:YES withpushID:[UAirship shared].deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    UALOG(@"PushNotificationPlugin: Failed To Register For Remote Notifications With Error: %@", error);
    [self raiseRegistration:NO withpushID:@""]; 
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
     UALOG(@"PushNotificationPlugin: Received remote notification: %@", userInfo);

     [[UAPush shared] handleNotification:userInfo applicationState:application.applicationState];
     [[UAPush shared] setBadgeNumber:0]; // zero badge after push received

    NSString *alert = [self alertForUserInfo:userInfo];
    NSMutableDictionary *extras = [self extrasForUserInfo:userInfo];

    [self raisePush:alert withExtras:extras];
}

#pragma mark Other stuff

- (void)dealloc {
    [UAAppDelegateSurrogate shared].surrogateDelegate = nil;
    [super dealloc];
}

- (void)failIfSimulator {
    if ([[[UIDevice currentDevice] model] compare:@"iPhone Simulator"] == NSOrderedSame) {
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                            message:@"You will not be able to recieve push notifications in the simulator."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];

        [someError show];
        [someError release];
    }
}

@end
