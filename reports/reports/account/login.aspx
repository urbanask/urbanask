<%@ page title="Log In" language="vb" masterpagefile="~/site.master" autoeventwireup="false"
    codebehind="login.aspx.vb" inherits="reports.login" %>

<asp:content id="headerContent" runat="server" contentplaceholderid="headContent">
</asp:content>
<asp:content id="bodyContent" runat="server" contentplaceholderid="mainContent">
    <h2>
        Log In
    </h2>
    <p>
        Please enter your username and password.
    </p>
    <asp:login id="loginUser" runat="server" enableviewstate="false" renderoutertable="false">
        <layouttemplate>
            <span class="failureNotification">
                <asp:literal id="failureText" runat="server"></asp:literal>
            </span>
            <asp:validationsummary id="loginUserValidationSummary" runat="server" cssclass="failureNotification"
                validationgroup="loginUserValidationGroup" />
            <div class="accountInfo">
                <fieldset class="login">
                    <legend>Account Information</legend>
                    <p>
                        <asp:label id="UserNameLabel" runat="server" associatedcontrolid="UserName">Username:</asp:label>
                        <asp:textbox id="UserName" runat="server" cssclass="textEntry"></asp:textbox>
                        <asp:requiredfieldvalidator id="UserNameRequired" runat="server" controltovalidate="UserName"
                            cssclass="failureNotification" errormessage="User Name is required." tooltip="User Name is required."
                            validationgroup="LoginUserValidationGroup">*</asp:requiredfieldvalidator>
                    </p>
                    <p>
                        <asp:label id="PasswordLabel" runat="server" associatedcontrolid="Password">Password:</asp:label>
                        <asp:textbox id="Password" runat="server" cssclass="passwordEntry" textmode="Password"></asp:textbox>
                        <asp:requiredfieldvalidator id="PasswordRequired" runat="server" controltovalidate="Password"
                            cssclass="failureNotification" errormessage="Password is required." tooltip="Password is required."
                            validationgroup="LoginUserValidationGroup">*</asp:requiredfieldvalidator>
                    </p>
                    <p>
                        <asp:checkbox id="RememberMe" runat="server" />
                        <asp:label id="RememberMeLabel" runat="server" associatedcontrolid="RememberMe" cssclass="inline">Keep me logged in</asp:label>
                    </p>
                </fieldset>
                <p class="submitButton">
                    <asp:button id="LoginButton" runat="server" commandname="Login" text="Log In" validationgroup="LoginUserValidationGroup" />
                </p>
            </div>
        </layouttemplate>
    </asp:login>
</asp:content>
