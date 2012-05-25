<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="profile-picture.aspx.vb" Inherits="tools.profilePicture" %>

<!doctype html>
<html>
<head>
<title>update profile picture</title>
<link rel="stylesheet" href="styles/Site.css" />
</head>

<body>
<form id="urlForm" runat="server">

<label for="url">url:</label><asp:TextBox id="url" runat="server"></asp:TextBox>
<asp:Button ID="save" runat="server" Text="save" />
<br />
<div id="pictureFrame"><img id="picture" /></div>
<div id="message" runat="server"></div>
</form>


<script src="tools.js"></script>
</body>

</html>





