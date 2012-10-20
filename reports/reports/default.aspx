<%@ page title="Home Page" language="vb" masterpagefile="~/site.master" autoeventwireup="false"
    codebehind="default.aspx.vb" inherits="reports._default" %>

<asp:content id="headerContent" runat="server" contentplaceholderid="headContent">
</asp:content>
<asp:content id="bodyContent" runat="server" contentplaceholderid="mainContent">
    <h2>
        Welcome to urbanAsk Reports!
    </h2>
    <p>
        <a href="dailymetrics.aspx" title="Daily Metrics">
            Daily Metrics</a>.
    </p>
</asp:content>
