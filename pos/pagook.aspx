<%@ Page Language="C#" AutoEventWireup="true" CodeFile="pagook.aspx.cs" Inherits="pos_pagook" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    
    <script src="../general/assets/vendor/jquery/dist/jquery.min.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <div style="text-align:center;padding-top:90px">
             <label id="lblMensagem" runat="server" style="font-size: 40px;font-family: sans-serif;font-weight: bold;color: red"></label>
        </div>
    </form>

    <script>
        $(document).ready(function () {
            setTimeout(function () {
                var idMaquina = $('#txtIDMaquina').val();
                window.location = "payment.aspx?id=" + idMaquina;
            }, 1000);
        });
    </script>

    <input type="text" id="txtIDMaquina" style="display:none" runat="server"/>
</body>
</html>
