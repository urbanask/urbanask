<%@ page language="vb" autoeventwireup="false" codebehind="Default.aspx.vb" inherits="EmailVerification._Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="Main" runat="server">
    <div>
        <div>Email:<asp:textbox runat="server" id="EmailTextbox"></asp:textbox></div>
        <asp:button runat="server" text="Verify" onclientclick="this.disabled = true;" usesubmitbehavior="false" id="VerifyButton" />
        <div><asp:label runat="server" id="Message"></asp:label></div>
    </div>
    </form>
</body>
</html>
