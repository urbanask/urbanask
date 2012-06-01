<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="questions.aspx.vb" Inherits="tools.questions" %>

<!doctype html>
<html>
<head>
<title>add questions</title>
<link rel="stylesheet" href="styles/Site.css" />
</head>

<body>
<form id="questionForm" runat="server">

<label for="url">question:</label><asp:TextBox id="question" MaxLength="50" runat="server"></asp:TextBox>
<asp:Button ID="save" runat="server" Text="save" />
<br />
<div id="message" runat="server"></div>
</form>


<script src="scripts/questions.js"></script>
</body>

</html>





