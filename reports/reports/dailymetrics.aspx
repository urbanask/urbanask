<%@ page title="Daily Metrics" language="vb" masterpagefile="~/site.master" autoeventwireup="false"
    codebehind="dailymetrics.aspx.vb" inherits="reports.dailymetrics" %>

<asp:content id="headerContent" runat="server" contentplaceholderid="headContent">
</asp:content>
<asp:content id="bodyContent" runat="server" contentplaceholderid="mainContent">
    <h2>
        Daily Metrics
    </h2>
    <p>
        <asp:sqldatasource id="DataSource" 
            connectionstring="<%$ ConnectionStrings:reportConnectionString %>" 
            runat="server" 
            selectcommand="<%$ appSettings:dailyMetricSelect %>"></asp:sqldatasource>
        <asp:gridview id="DailyMetrics" runat="server" autogeneratecolumns="False" 
            datasourceid="DataSource">
            <columns>
                <asp:boundfield datafield="date" dataformatstring="{0:d}" headertext="Date" 
                    sortexpression="date" />
                <asp:boundfield datafield="uniqueLogins" headertext="Logins" 
                    sortexpression="uniqueLogins" >
                <itemstyle horizontalalign="Right" />
                </asp:boundfield>
                <asp:boundfield datafield="uniqueLoginsWithNoAccount" headertext="No Account" 
                    sortexpression="uniqueLoginsWithNoAccount" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
                <asp:boundfield datafield="newUsers" headertext="New" 
                    sortexpression="newUsers" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
                <asp:boundfield datafield="oneDayRetention" headertext="Day" 
                    sortexpression="oneDayRetention" dataformatstring="{0:P}" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
                <asp:boundfield datafield="oneWeekRetention" headertext="Week" 
                    sortexpression="oneWeekRetention" dataformatstring="{0:P}" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
                <asp:boundfield datafield="oneMonthRetention" headertext="Month" 
                    sortexpression="oneMonthRetention" dataformatstring="{0:P}" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
                <asp:boundfield datafield="questions" headertext="Questions" 
                    sortexpression="questions" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
                <asp:boundfield datafield="questioners" headertext="Questioners" 
                    sortexpression="questioners" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
                <asp:boundfield datafield="answers" headertext="Answers" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
                <asp:boundfield datafield="answerers" headertext="Answerers" 
                    sortexpression="answerers" >
                    <itemstyle horizontalalign="Right" /></asp:boundfield>
            </columns>
        </asp:gridview>
    </p>
</asp:content>
