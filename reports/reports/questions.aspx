<%@ page title="Questions" language="vb" masterpagefile="~/site.master" autoeventwireup="false"
    codebehind="questions.aspx.vb" inherits="reports.questions" %>

<asp:content id="headerContent" runat="server" contentplaceholderid="headContent">
</asp:content>
<asp:content id="bodyContent" runat="server" contentplaceholderid="mainContent">
    <h2>
        Questions
    </h2>
    <p>
        <asp:sqldatasource id="DataSource" 
            connectionstring="<%$ ConnectionStrings:gabsConnectionString %>" 
            runat="server" 
            selectcommand="<%$ appSettings:questionSelect %>"></asp:sqldatasource>
        <asp:gridview id="QuestionList" runat="server" autogeneratecolumns="False" 
            datasourceid="DataSource">
            <columns>
                <asp:boundfield datafield="question" headertext="question" 
                    sortexpression="question" />
                <asp:boundfield datafield="creationTimestamp" headertext="creationTimestamp" 
                    sortexpression="creationTimestamp" />
            </columns>
        </asp:gridview>
    </p>
</asp:content>
