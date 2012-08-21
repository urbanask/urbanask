<%@ page title="Home Page" language="vb" masterpagefile="~/Site.Master" autoeventwireup="false" codebehind="Default.aspx.vb" inherits="TwitterDotNetSample._Default" %>

<asp:content id="HeaderContent" runat="server" contentplaceholderid="HeadContent">
</asp:content>
<asp:content id="BodyContent" runat="server" contentplaceholderid="MainContent">
    <asp:button id="SignInWithTwitter" runat="server" text="Sign in with Twitter" visible="true" />
    <div id="Output" runat="server"></div>
</asp:content>
