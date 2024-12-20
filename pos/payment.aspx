<%@ Page Language="C#" AutoEventWireup="true" CodeFile="payment.aspx.cs" Inherits="pos_payment" %>

<!DOCTYPE html>
<html>
  <head>
    <title>Javascript Numpad</title>
    
    <!-- (A) LOAD JS + CSS -->
    <!--
    <link rel="stylesheet" href="numpad-light.css"/>
    -->
    <link rel="stylesheet" href="../pos/numpad-dark.css"/>
    <script src="../pos/numpad.js"></script>
    <script src="../general/assets/vendor/jquery/dist/jquery.min.js"></script>

 <style type="text/css">

     .botao {
        color: #fff;
        border-color: seagreen;
        background-color:seagreen;
        height: 60px;
        width: 250px;
        border-radius: 6px;
    }

 </style>


  </head>
  <body style="text-align:center; font-size:14px;padding-top:70px">
      <span id="lblPagamento" style="font-size: 40px;font-family: sans-serif;font-weight: bold;color: #f5365c;">Pagamento</span><br /><br />
      <div id="divAcao">
        <input type="text" id="txtPagamento" style="font-size: 40px;width: 80%;"/><br /><br />
        <input type="button" class="botao" value="Pagar" title="Pagar" onclick="paga();" />
      </div>
    
      <script>
          $(document).ready(function () {
              var pago = $('#txtPago').val();
          });

          


        window.addEventListener("load", function () {
            numpad.attach({ target: "txtPagamento" });
            document.getElementById('txtPagamento').click();
        });

        function paga() {
            var idMaquina = $('#txtIDMaquina').val();
            var valor = $('#txtPagamento').val();
            if (valor != '' && valor != '0') {
                $('#divAcao').hide();
                $('#lblPagamento').html('A Pagar. Aguarde.');

                if (valor.includes('.'))
                    valor = valor.replace('.', '');
                else
                    valor = valor + '00';


                $.ajax({
                    type: "POST",
                    url: "payment.aspx/paga",
                    data: '{"idMaquina":"' + idMaquina + '","valor":"' + valor + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var operacaoid = res.d;
                        window.location = "verificapago.aspx?idMaquina=" + idMaquina + "&operacaoid=" + operacaoid + "&valor=" + valor;
                    }
                });                
            }
        }


      </script>

      <input type="text" id="txtIDMaquina" style="display:none" runat="server"/>
      <input type="text" id="txtPago" style="display:none" runat="server"/>
  </body>
</html>