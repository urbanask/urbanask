<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="VerifyEmail.aspx.vb" Inherits="EmailVerification.VerifyEmail" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:label id="NoRecordFound" cssclass="warning" runat="server">Unable to validate email address.</asp:label>    
        <asp:label id="SuccessMessage" cssclass="warning" visible="false" runat="server">{0} has been successfully validated.</asp:label>
    </div>
    </form>
</body>
</html>
