<%@ Page Title="Home Page" Language="vb" AutoEventWireup="false"
    CodeBehind="profile-picture.aspx.vb" Inherits="tools._Default" %>
<html>
<head>
<title>update profile picture</title>
</head>

<body>
<form id="urlForm" runat="server">

<label for="userId">userId:</label><asp:TextBox id="userId" runat="server"></asp:TextBox>
<label for="url">url:</label><asp:TextBox id="url" runat="server"></asp:TextBox>
<asp:Button ID="save" runat="server" Text="save" />

</form>
</body>

</html>