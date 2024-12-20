<%@ Page Language="C#" AutoEventWireup="true" CodeFile="lista_faturas_fornecedores.aspx.cs" Inherits="lista_faturas_fornecedores" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Grilo Car Service Software - Pagamentos a Fornecedores">
    <meta name="author" content="André Lourenço">
    <title>Grilo Car Service Software - Pagamentos a Fornecedores</title>
    <!-- Favicon -->
    <link href="../Img/favicon.ico" rel="icon" type="image/ico">
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
    <!-- Icons -->
    <link href="../general/assets/vendor/nucleo/css/nucleo.css" rel="stylesheet">
    <link href="../general/assets/vendor/@fortawesome/fontawesome-free/css/all.min.css" rel="stylesheet">
    <!-- Argon CSS -->
    <link type="text/css" href="../general/assets/css/argon.css?v=1.0.0" rel="stylesheet">
    <!-- Alerts -->
    <link type="text/css" href="../vendors/sweetalert2/sweetalert2.min.css" rel="stylesheet" />
    <link type="text/css" href="../alertify/css/alertify.min.css" rel="stylesheet" />
    <link type="text/css" href="../alertify/css/themes/default.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.8.0/css/bootstrap-datepicker.css">

    <style>
        .bg-gradient-primary {
            background: linear-gradient(87deg, #E3101A, #E3101A 100%) !important;
        }

        #divLoading {
            border: solid 3px gray;
            z-index: 999999999999999999999999;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            margin: auto;
            background-color: white;
            height: 350px;
            width: 61%;
        }

        #divShowDocs {
            border: solid 3px gray;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            margin: auto;
            background-color: white;
            height: 95%;
            width: 95%;
        }

        #overlay {
            position: fixed; /* Sit on top of the page content */
            display: none; /* Hidden by default */
            width: 100%; /* Full width (cover the whole page) */
            height: 100%; /* Full height (cover the whole page) */
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,0.5); /* Black background with opacity */
            z-index: 9999999999; /* Specify a stack order in case you're using a different order for other elements */
            cursor: pointer; /* Add a pointer on hover */
        }

        #overlayShowDocs {
            position: fixed; /* Sit on top of the page content */
            display: none; /* Hidden by default */
            width: 100%; /* Full width (cover the whole page) */
            height: 100%; /* Full height (cover the whole page) */
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,0.5); /* Black background with opacity */
            z-index: 9999999999; /* Specify a stack order in case you're using a different order for other elements */
        }

        ::placeholder { /* Chrome, Firefox, Opera, Safari 10.1+ */
          color: black !important;
          opacity: 1; /* Firefox */
        }

        :-ms-input-placeholder { /* Internet Explorer 10-11 */
          color: black !important;
        }

        ::-ms-input-placeholder { /* Microsoft Edge */
          color: black !important;
        }

        .th_text {
            font-weight: bold !important;
            color: #000000 !important;
        }

        .th_text_centered {
            text-align: center !important;
        }

        .invoice_selected {
            background-color: green !important;
        }

        .invoice_not_selected {
            background-color: yellow !important;
        }

        .dialogWidth {
            width: 90% !important;
            max-width: 100% !important;
        }
    </style>
</head>

<body>

    <!-- Main content -->
    <div class="main-content">

        <div id="overlay"></div>
        <div id="divLoading" style="display: none">
            <table style="width: 100%; height: 100%; text-align: center; vertical-align: middle">
                <tr>
                    <td style="vertical-align: bottom">
                        <img src="../general/assets/img/theme/preloader.gif" />
                    </td>
                </tr>
                <tr>
                    <td style="font-size: 17px; vertical-align: top; font-weight: bold"><span id="spanLoading">A reiniciar serviço, por favor aguarde...</span></td>
                </tr>
            </table>
        </div>
        <div id="overlayShowDocs">
            <div id="divShowDocs">
                <div class="row" id="fileSelector" style="height: auto; width: 100%">
                    <div class="col-md-3" style="text-align:right">
                        <img src="../general/assets/img/theme/setae_off.png" style="height: 20px; width: auto; cursor: pointer" onclick="previousFile();" />
                    </div>
			        <div class="col-md-6" style="text-align:center; color: black;">
                        <h3 id="fileHeader"></h3>
			        </div>
			        <div class="col-md-3" style="text-align:left">
                        <img src="../general/assets/img/theme/setad_off.png" style="height: 20px; width: auto; cursor: pointer" onclick="nextFile();" />
			        </div>
                </div>
                <div class="row" style="height: auto;" id="divDoc">
                    <div class="col-md-12">
                        <embed src="" style="height: 100%; width: 100%;" id="doc" />
                    </div>
                </div>
                <div class="row" style="height: auto" id="divButton">
                    <div class="col-md-12">
                        <input type="button" class="btn btn-sm btn-primary" onclick="closeDivDocs();" value="OK" style="width: 100%;"/>
                    </div>
                </div>
            </div>
        </div>

        <!-- Top navbar -->
        <nav class="navbar navbar-top navbar-expand-md navbar-dark" id="navbar-main">
            <div class="container-fluid">
                <!-- Brand -->
                <a class="h4 mb-0 text-white text-uppercase d-none d-lg-inline-block">Pagamentos a Fornecedores</a>
                <!-- Form -->
                

                <!-- User -->
                <ul class="navbar-nav align-items-center d-none d-md-flex">
                    <li class="nav-item dropdown">
                        <a class="nav-link pr-0" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <div class="media align-items-center">

                                <div class="media-body ml-2 d-none d-lg-block">
                                    <span id="spanNomeUser" class="mb-0 text-sm  font-weight-bold"></span>
                                </div>
                            </div>
                        </a>
                        <div class="dropdown-menu dropdown-menu-arrow dropdown-menu-right">
                            <div class=" dropdown-header noti-title">
                                <h6 id="spanOla" class="text-overflow m-0"></h6>
                            </div>



                            <div class="dropdown-divider"></div>
                            <a href="#!" class="dropdown-item" onclick="finishSession();">
                                <i class="ni ni-button-power"></i>
                                <span>Terminar sessão</span>
                            </a>
                        </div>
                    </li>
                </ul>



            </div>
        </nav>



        <!-- Header -->
        <div class="header bg-gradient-primary pb-8 pt-5 pt-md-8">
            <div class="container-fluid">
                <div class="header-body">
                    <!-- Card stats -->
                    <div class="row">
                        <div class="col-xl-3 col-lg-6" id="header1">
                            <div class="card card-stats mb-4 mb-xl-0">
                                <div class="card-body">
                                    <div class="row" id="subheader1">
                                        <div class="col">
                                            <h5 id="label1" class="card-title text-uppercase text-muted mb-0"></h5>
                                            <span id="total1" class="h2 font-weight-bold mb-0"></span>
                                        </div>
                                        <div class="col-auto">
                                            <div class="icon icon-shape bg-red text-white rounded-circle shadow">
                                                <i class="fas fa-users"></i>
                                            </div>
                                        </div>
                                    </div>
                                    <p class="mt-3 mb-0 text-muted text-sm">
                                        <span id="rodape1" class="text-nowrap"></span>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-3 col-lg-6" id="header2">
                            <div class="card card-stats mb-4 mb-xl-0">
                                <div class="card-body">
                                    <div class="row" id="subheader2">
                                        <div class="col">
                                            <h5 id="label2" class="card-title text-uppercase text-muted mb-0"></h5>
                                            <span id="total2" class="h2 font-weight-bold mb-0"></span>
                                        </div>
                                        <div class="col-auto">
                                            <div class="icon icon-shape bg-yellow text-white rounded-circle shadow">
                                                <i class="fas fa-wrench"></i>
                                            </div>
                                        </div>
                                    </div>
                                    <p class="mt-3 mb-0 text-muted text-sm">
                                        <span id="rodape2" class="text-nowrap"></span>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-3 col-lg-6" id="header3">
                            <div class="card card-stats mb-4 mb-xl-0">
                                <div class="card-body">
                                    <div class="row" id="subheader3">
                                        <div class="col">
                                            <h5 id="label3" class="card-title text-uppercase text-muted mb-0"></h5>
                                            <span id="total3" class="h2 font-weight-bold mb-0"></span>
                                        </div>
                                        <div class="col-auto">
                                            <div class="icon icon-shape bg-info text-white rounded-circle shadow">
                                                <i class="fas fa-car"></i>
                                            </div>
                                        </div>
                                    </div>
                                    <p class="mt-3 mb-0 text-muted text-sm">
                                        <span id="rodape3" class="text-nowrap"></span>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="col-xl-3 col-lg-6" id="header4">
                            <div class="card card-stats mb-4 mb-xl-0">
                                <div class="card-body">
                                    <div class="row" id="subheader4">
                                        <div class="col">
                                            <h5 id="label4" class="card-title text-uppercase text-muted mb-0"></h5>
                                            <span id="total4" class="h2 font-weight-bold mb-0"></span>
                                        </div>
                                        <div class="col-auto">
                                            <div class="icon icon-shape bg-warning text-white rounded-circle shadow">
                                                <i class="fas fa-screwdriver"></i>
                                            </div>
                                        </div>
                                    </div>
                                    <p class="mt-3 mb-0 text-muted text-sm">
                                        <span id="rodape4" class="text-nowrap"></span>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>




        <!-- Page content -->
        <div class="container-fluid mt--7">
            <!-- Table -->
            <div class="row">
                <div class="col">
                    <div class="card shadow">
                        <div class="card-header border-0">
                            <table style="width: 100%">
                                <tr>
                                    <td style="width: 50%; max-width: 50% !important;">
                                        <div style="float:left">
                                            <h3 class="mb-0">Pagamentos a Fornecedores</h3>
                                        </div>
                                    </td>
                                    <td style="text-align: right; width: 35%; max-width: 35% !important;">
                                        <form id="formPesquisa" class="navbar-search navbar-search-dark form-inline mr-3 d-none d-md-flex ml-lg-auto" onsubmit="return false;" onkeypress="keyPesquisa(event);">
                                            <div class="form-group mb-0" style="width:100%;">
                                                <div class="input-group input-group-alternative" style="width: 100%;">
                                                    <div class="input-group-prepend">
                                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                                    </div>
                                                    <input id="txtPesquisa" class="form-control" placeholder="Pesquisar..." type="text" style="color:black">
                                                </div>
                                            </div>
                                        </form>
                                    </td>
                                    <td style="width: 15%; max-width: 15% !important; text-align: right;">
                                        <div id="divCriaNovoPagamento">
                                            <a class="btn btn-sm btn-primary" onclick="novo();" style="color: #FFFFFF;">
                                                <span id="spanBtnAlteraStatus"><i class="fa fa-file-invoice" aria-hidden="true"></i>  Criar novo pagamento</span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <table style="width: 100%">
                                <tr>
                                    <td style="text-align: left; width: 22.5%; max-width: 22.5% !important;">
                                        <div class="form-group" id="mininvoicedatepicker">
                                            <label class="form-control-label" for="txtMinInvoiceDate">Data da Fatura<br />De:</label>
                                            <input type="text" onfocusout="getData();" id="txtMinInvoiceDate" class="form-control form-control-alternative" placeholder="Data Mín Fatura">
                                        </div>
                                    </td>
                                    <td style="text-align: left; width: 22.5%; max-width: 22.5% !important;">
                                        <div class="form-group" id="maxinvoicedatepicker">
                                            <label class="form-control-label" for="txtMinInvoiceDate"><br />a:</label>
                                            <input type="text" onfocusout="getData();" id="txtMaxInvoiceDate" class="form-control form-control-alternative" placeholder="Data Max Fatura">
                                        </div>
                                    </td>
                                    <td style="text-align: left; width: 10%; max-width: 10% !important;"></td>
                                    <td style="text-align: left; width: 22.5%; max-width: 22.5% !important;">
                                        <div class="form-group" id="minduedatepicker">
                                            <label class="form-control-label" for="txtMinDueDate">Data de Vencimento<br />De:</label>
                                            <input type="text" onfocusout="getData(); "id="txtMinDueDate" class="form-control form-control-alternative" placeholder="Data Mín Vencimento">
                                        </div>
                                    </td>
                                    <td style="text-align: left; width: 22.5%; max-width: 22.5% !important;">
                                        <div class="form-group" id="maxduedatepicker">
                                            <label class="form-control-label" for="txtMaxDueDate"><br />a:</label>
                                            <input type="text" onfocusout="getData();" id="txtMaxDueDate" class="form-control form-control-alternative" placeholder="Data Max Vencimento">
                                        </div>
                                    </td>
                                </tr>
                                <tr id="rowBtnsPayment" class="variaveis">
                                    <td colspan="2" style="text-align:left; width: 45%; max-width: 45% !important">
                                        <div id="divBtnGerarDadosPagamento" style="width: 100%;">
                                            <a class="btn btn-sm btn-primary" onclick="gerarDadosPagamento();" style="color: #FFFFFF; width: 100%">
                                                <span id="spanBtnGerarDadosPagamento"><i class="fa fa-file-invoice" aria-hidden="true"></i>  Gerar Dados Pagamento</span>
                                            </a>
                                        </div>
                                    </td>
                                    <td style="text-align: center; width: 10%; max-width: 10% !important;"></td>
                                    <td colspan="2" style="text-align: right; width: 45%; max-width: 45% !important;">
                                        <div id="divBtnMarcarFaturasPagas" style="width: 100%;">
                                            <a class="btn btn-sm btn-primary" onclick="pagarFaturas();" style="color: #FFFFFF; width: 100%">
                                                <span id="spanBtnMarcarFaturasPagas"><i class="fa fa-file-invoice" aria-hidden="true"></i>  Pagar Faturas</span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <form id="formUploadProviders" runat="server" class="variaveis">
                                <table style="width:100%; height: auto;">
                                    <tr>
                                        <td style="width: 30%; max-width: 30% !important; text-align: center;">
                                            <div>
                                                <p class='text-danger' id='fileUploadedName' runat='server'><br />Nenhum ficheiro selecionado</p>
                                            </div>                                        
                                        </td>
                                        <td style="width: 30%; max-width: 30% !important; text-align: center;">
                                            <div>
                                                <asp:Button runat="server" Text="Carregar Fornecedores para o Sistema" ID="uploadButton" OnClick="Upload_Click" CssClass="btn btn-sm btn-primary" />
                                            </div>                                        
                                        </td>
                                        <td style="width: 40%; max-width: 40% !important; text-align: right;">
                                            <div>
                                                <p class='text-danger' id='uploadFileDanger' runat='server'></p>
                                                <p class='text-sucess' id='uploadFileSuccess' runat='server'></p>
                                                <asp:FileUpload ID="FileUploadControl" runat="server" CssClass="variaveis" />
                                                <asp:TextBox ID="userID" runat="server" CssClass="variaveis" />
                                                <asp:TextBox ID="invoiceID" runat="server" CssClass="variaveis" />
                                            </div>                                        
                                        </td>
                                    </tr>
                                </table>
                            </form>
                        </div>
                        <div class="table-responsive">
                            <div id="divGrelhaRegistos" style="margin-bottom:100px;"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <footer class="footer">
                <div class="row align-items-center justify-content-xl-between">
                    <div class="col-xl-6">
                        <div class="copyright text-center text-xl-left text-muted">
                        </div>
                    </div>
                </div>
            </footer>
        </div>
    </div>

    <!-- Argon Scripts -->
    <!-- Core -->
    <script src="../general/assets/vendor/jquery/dist/jquery.min.js"></script>
    <script src="../general/assets/vendor/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Argon JS -->
    <script src="../general/assets/js/argon.js?v=1.0.0"></script>
    <script src="../vendors/sweetalert2/sweetalert2.min.js"></script>
    <script src="../alertify/alertify.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.8.0/js/bootstrap-datepicker.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.8.0/locales/bootstrap-datepicker.pt.min.js"></script>

    <script>
        var ordFornecedor = 0;
        var ordNumero = 0;
        var ordData = 0;
        var ordDataVencimento = 0;
        var ordPaga = 0;
        var ordValor = 0;
        var administrador;
        var anyfileuploadstring = "";
        var docsToBeShowed;
        var docAmount = 0;
        var docSelected = 0;

        $(document).ready(function () {
            loga();
            setAltura();
            getTotals();
            setInterval(function () {
                getTotals();
            }, 5000);

            $("#txtPesquisa").focus();

            anyfileuploadstring = $('#fileUploadedName').html();

            $('#FileUploadControl').change(function () {
                var path = $(this).val();
                if (path != '' && path != null) {
                    var q = path.substring(path.lastIndexOf('\\') + 1);
                    $('#fileUploadedName').html('<br />' + q);
                    $('#uploadButton').click();
                }
                else {
                    $('#fileUploadedName').html(anyfileuploadstring);
                }
            });
        });

        $(window).resize(function () {
            setAltura();
        });

        function finishSession() {
            window.top.location = "../general/login.aspx";
        }

        function loga() {
            var id = localStorage.loga;
            $('#userID').val(id);

            if (id == null || id == 'null' || id == undefined || id == '') {
                swal({
                    title: "GRILO CAR SERVICE SOFTWARE",
                    text: 'Utilizador Inválido!',
                    type: "warning",
                    showCancelButton: false,
                    confirmButtonColor: '#007351',
                    cancelButtonColor: '#d33',
                    confirmButtonText: "Confirmar"
                }).then(function () {
                    finishSession();
                });
                return;
            }

            $.ajax({
                type: "POST",
                url: "index.aspx/trataExpiracao",
                data: '{"i":"' + id + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var ret = parseInt(dados[0]);
                    var retMsg = dados[1];
                    administrador = parseInt(dados[2]);
                    var nome = dados[3];

                    // OK
                    if (ret == 0) {
                        swal({
                            title: "GRILO CAR SERVICE SOFTWARE",
                            text: retMsg,
                            type: "warning",
                            showCancelButton: false,
                            confirmButtonColor: '#007351',
                            cancelButtonColor: '#d33',
                            confirmButtonText: "Confirmar"
                        }).then(function () {
                            finishSession();
                        });
                        return;
                    }

                    $('#spanNomeUser').html(nome);
                    $('#spanOla').html("Olá, " + nome.split(' ')[0] + "!");
                    setDatePicker();
                    getData();

                    if (administrador == 0) {
                        $('#divCriaNovoPagamento').fadeOut();
                    }
                    else {
                        $('#divCriaNovoPagamento').fadeIn();
                    }
                }
            });
        }

        function setAltura() {
            $("#fraContent").height($(window).height());
        }

        function keyPesquisa(e) {
            if (e.keyCode == 13) {
                checkFocus();
            }
        }

        function checkFocus() {
            if ($("#txtPesquisa").is(":focus")) {
                getData();
                return;
            }

            if ($("#txtMinInvoiceDate").is(":focus")) {
                $('#txtMaxInvoiceDate').focus();
                return;
            }

            if ($("#txtMaxInvoiceDate").is(":focus")) {
                $('#txtMinDueDate').focus();
                return;
            }

            if ($("#txtMinDueDate").is(":focus")) {
                $('#txtMaxDueDate').focus();
                return;
            }

            if ($("#txtMaxDueDate").is(":focus")) {
                $('#txtMaxDueDate').blur();
                return;
            }
        }

        function loadUrl(url) {
            window.location = url;
        }

        // Web services

        function getData() {
            loadingOn('A carregar os pagamentos a fornecedores. Por favor aguarde...');
            var pesquisa = $('#txtPesquisa').val();
            var order = "";
            var minInvoiceDate = $('#txtMinInvoiceDate').val();
            var maxInvoiceDate = $('#txtMaxInvoiceDate').val();
            var minDueDate = $('#txtMinDueDate').val();
            var maxDueDate = $('#txtMaxDueDate').val();

            if (ordFornecedor == 0 && ordNumero == 0 && ordData == 0 && ordDataVencimento == 0 && ordPaga == 0) {
                order = ' ORDER BY paga asc, data_vencimento asc, data_fatura desc ';
            }
            else {
                order = ' ORDER BY ';

                if (ordFornecedor != 0) {
                    order += ordFornecedor == -1 ? ' name_provider desc ' : ' name_provider asc ';
                }
                else if (ordNumero != 0) {
                    order += ordNumero == -1 ? ' numero desc ' : ' numero asc ';
                }
                else if (ordData != 0) {
                    order += ordData == -1 ? ' data_fatura desc ' : ' data_fatura asc ';
                }
                else if (ordDataVencimento != 0) {
                    order += ordDataVencimento == -1 ? ' data_vencimento desc ' : ' data_vencimento asc ';
                }
                else if (ordPaga != 0) {
                    order += ordPaga == -1 ? ' paga desc ' : ' paga asc ';
                }
            }

            $.ajax({
                type: "POST",
                url: "lista_faturas_fornecedores.aspx/getGrelha",
                data: '{"pesquisa":"' + pesquisa + '","order":"' + order + '","admin":"' + administrador + '","min_invoice_date":"' + minInvoiceDate + '","max_invoice_date":"' + maxInvoiceDate + '","min_due_date":"' + minDueDate + '","max_due_date":"' + maxDueDate + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    $('#divGrelhaRegistos').html(res.d);
                    getTotals();
                }
            });
        }

        function getTotals() {
            var id = null;
            $.ajax({
                type: "POST",
                url: "index.aspx/getTotais",
                data: '{"id":"' + id + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('@');

                    var label1 = dados[0];
                    var total1 = dados[1];
                    var rodape1 = dados[2];

                    $('#label1').html(label1);
                    $('#total1').html(total1);
                    $('#rodape1').html(rodape1);

                    var label2 = dados[3];
                    var total2 = dados[4];
                    var rodape2 = dados[5];

                    $('#label2').html(label2);
                    $('#total2').html(total2);
                    $('#rodape2').html(rodape2);

                    var label3 = dados[6];
                    var total3 = dados[7];
                    var rodape3 = dados[8];

                    $('#label3').html(label3);
                    $('#total3').html(total3);
                    $('#rodape3').html(rodape3);

                    var label4 = dados[9];
                    var total4 = dados[10];
                    var rodape4 = dados[11];

                    $('#label4').html(label4);
                    $('#total4').html(total4);
                    $('#rodape4').html(rodape4);

                    loadingOff();
                }
            });
        }

        function editar(id) {
            loadUrl('config_ficha_fatura_fornecedor.aspx?id=' + id);
        }

        function eliminar(id) {
            swal({
                title: 'Eliminar pagamento a fornecedor',
                text: "O pagamento ao fornecedor será eliminado. Confirma?",
                type: 'question',
                showCancelButton: true,
                confirmButtonColor: '#007351',
                cancelButtonColor: '#d33',
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (isConfirm) {
                if (isConfirm) {
                    delRow(id);
                }
            });
        }

        function delRow(id) {
            $.ajax({
                type: "POST",
                url: "lista_faturas_fornecedores.aspx/delRow",
                data: '{"id":"' + id + '","idUser":"' + localStorage.loga + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var res = dados[0];
                    var resMsg = dados[1];

                    if (parseInt(res) <= 0) {
                        sweetAlertWarning("Eliminar pagamento a fornecedor", resMsg);
                    }
                    else {
                        $('#txtPesquisa').val('');
                        ordFornecedor = 0;
                        ordNumero = 0;
                        ordData = 0;
                        ordDataVencimento = 0;
                        ordPaga = 0;
                        ordValor = 0;
                        getData();
                    }
                }
            });
        }

        function novo() {
            loadUrl('config_ficha_fatura_fornecedor.aspx');
        }

        function visualizar(id) {
            $.ajax({
                type: "POST",
                url: "index.aspx/generateViewInfo",
                data: '{"idUser":"' + localStorage.loga + '","id":"' + id + '","tipo":"' + 'FATURAS FORNECEDORES' + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d;

                    swal({
                        title: "<strong>DADOS DO PAGAMENTO</strong>",
                        html: dados,
                        showCancelButton: false,
                        confirmButtonColor: "#DD6B55",
                        confirmButtonText: "OK"
                    }).then(function () {

                    });
                }
            });
        }

        function verDocs(id) {
            $.ajax({
                type: "POST",
                url: "lista_faturas_fornecedores.aspx/getFiles",
                data: '{"idUser":"' + localStorage.loga + '","id":"' + id + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('@');
                    docAmount = parseInt(dados[0]);
                    var msg = dados[1];

                    if (docAmount <= 0) {
                        sweetAlertWarning('FATURAS', msg);
                    }
                    else {
                        if (docAmount == 1) {
                            var url = '../faturas/' + msg;
                            $('#doc').attr('src', url);
                            $('#fileHeader').html('1/' + docAmount);
                        }
                        else {
                            docsToBeShowed = msg.split('<#SEP#>');
                            docSelected = 0;
                            var url = '../faturas/' + docsToBeShowed[docSelected];
                            $('#doc').attr('src', url);
                            $('#fileHeader').html('1/' + docAmount);
                        }
                        
                        showDivDocs();
                    }
                }
            });
        }

        function ordenaFornecedor() {
            ordNumero = 0;
            ordData = 0;
            ordDataVencimento = 0;
            ordPaga = 0;

            if (ordFornecedor == 0) {
                ordFornecedor = 1;
            }
            else {
                ordFornecedor = ordFornecedor * (-1);
            }

            getData();
        }

        function ordenaNumero() {
            ordFornecedor = 0;
            ordData = 0;
            ordDataVencimento = 0;
            ordPaga = 0;

            if (ordNumero == 0) {
                ordNumero = 1;
            }
            else {
                ordNumero = ordNumero * (-1);
            }

            getData();
        }

        function ordenaDataFatura() {
            ordNumero = 0;
            ordFornecedor = 0;
            ordDataVencimento = 0;
            ordPaga = 0;

            if (ordData == 0) {
                ordData = 1;
            }
            else {
                ordData = ordData * (-1);
            }

            getData();
        }

        function ordenaDataVencimento() {
            ordFornecedor = 0;
            ordData = 0;
            ordNumero = 0;
            ordPaga = 0;

            if (ordDataVencimento == 0) {
                ordDataVencimento = 1;
            }
            else {
                ordDataVencimento = ordDataVencimento * (-1);
            }

            getData();
        }

        function ordenaPaga() {
            ordNumero = 0;
            ordData = 0;
            ordDataVencimento = 0;
            ordFornecedor = 0;

            if (ordPaga == 0) {
                ordPaga = 1;
            }
            else {
                ordPaga = ordPaga * (-1);
            }

            getData();
        }

        function sweetAlertBasic(msg) {
            swal(msg);
        }

        function sweetAlertError(subject, msg) {
            swal(
                subject,
                msg,
                'error'
            )
        }

        function sweetAlertInfo(subject, msg) {
            swal(
                subject,
                msg,
                'info'
            )
        }

        function sweetAlertWarning(subject, msg) {
            swal(
                subject,
                msg,
                'warning'
            )
        }

        function sweetAlertSuccess(subject, msg) {
            swal(
                subject,
                msg,
                'success'
            )
        }

        function sweetAlertQuestion(subject, msg) {
            swal(
                subject,
                msg,
                'question'
            )
        }

        function loadingOn(msg) {
            overlayOn();
            $('#spanLoading').html(msg);
            $('#divLoading').show();
        }

        function loadingOff() {
            overlayOff();
            $('#divLoading').hide();
        }

        function overlayOn() {
            $('#overlay').show();
        }

        function overlayOff() {
            $('#overlay').hide();
        }

        function simulateClickOnFileUploadButton(id) {
            $('#invoiceID').val(id);
            $('#FileUploadControl').click();
        }

        function getFirstDayOfMonth(year, month) {
            return new Date(year, month, 1);
        }

        function getLastDayOfMonth(year, month) {
            return new Date(year, month + 1, 0);
        }

        function addMonths(numOfMonths, date) {
            var newDate = new Date(date);
            newDate.setMonth(date.getMonth() + numOfMonths);

            return newDate;
        }

        function convertDateToStr(date) {
            var str = "";
            var minDay = parseInt(date.getDate());
            var minMonth = parseInt(date.getMonth()) + 1;
            var minYear = parseInt(date.getFullYear());

            if (minDay < 10) {
                str += '0' + minDay;
            }
            else {
                str += '' + minDay;
            }

            if (minMonth < 10) {
                str += '/0' + minMonth;
            }
            else {
                str += '/' + minMonth;
            }

            str += '/' + minYear;

            return str;
        }

        function setDatePicker() {
            var today = new Date();
            var minDate = getFirstDayOfMonth(new Date(today).getFullYear(), 0);
            var maxDate = getLastDayOfMonth(new Date(today).getFullYear(), new Date(today).getMonth());
            var minDueDate = getFirstDayOfMonth(new Date(today).getFullYear(), new Date(today).getMonth());
            var maxDueDate = addMonths(1, new Date(minDueDate));// = addMonth(1, minDueDate);
            maxDueDate = getLastDayOfMonth(maxDueDate.getFullYear(), maxDueDate.getMonth());

            $('#txtMinInvoiceDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtMinInvoiceDate').datepicker('setDate', minDate);
            $('#txtMinInvoiceDate').val(convertDateToStr(minDate));

            $('#txtMaxInvoiceDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtMaxInvoiceDate').datepicker('setDate', maxDate);
            $('#txtMaxInvoiceDate').val(convertDateToStr(maxDate));

            $('#txtMinDueDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtMinDueDate').datepicker('setDate', minDueDate);
            $('#txtMinDueDate').val(convertDateToStr(minDueDate));

            $('#txtMaxDueDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtMaxDueDate').datepicker('setDate', maxDueDate);
            $('#txtMaxDueDate').val(convertDateToStr(maxDueDate));
        }

        function selectAllInvoices() {
            var checked = false;

            if ($('#selectAllInvoicesIcon').hasClass('invoice_not_selected')) {
                checked = true;
                $('#selectAllInvoicesIcon').removeClass('invoice_not_selected');
                $('#selectAllInvoicesIcon').addClass('invoice_selected');
            }
            else {
                checked = false;
                $('#selectAllInvoicesIcon').removeClass('invoice_selected');
                $('#selectAllInvoicesIcon').addClass('invoice_not_selected');
            }

            for (i = 0; i < parseInt($('#countInvoices').html()); i++) {
                if (checked) {
                    $('#invoiceSelectIcon' + i).removeClass('invoice_not_selected');
                    $('#invoiceSelectIcon' + i).addClass('invoice_selected');
                }
                else {
                    $('#invoiceSelectIcon' + i).removeClass('invoice_selected');
                    $('#invoiceSelectIcon' + i).addClass('invoice_not_selected');
                }
            }

            checkBtnsStatus();
        }

        function changeInvoiceStatus(x) {
            if ($('#invoiceSelectIcon' + x).hasClass('invoice_not_selected')) {
                $('#invoiceSelectIcon' + x).removeClass('invoice_not_selected');
                $('#invoiceSelectIcon' + x).addClass('invoice_selected');

                checkAllInvoicesSelected();
            }
            else {
                $('#invoiceSelectIcon' + x).removeClass('invoice_selected');
                $('#invoiceSelectIcon' + x).addClass('invoice_not_selected');

                $('#selectAllInvoicesIcon').removeClass('invoice_selected');
                $('#selectAllInvoicesIcon').removeClass('invoice_not_selected');
                $('#selectAllInvoicesIcon').addClass('invoice_not_selected');
            }

            checkBtnsStatus();
        }

        function checkAllInvoicesSelected() {
            for (i = 0; i < parseInt($('#countInvoices').html()); i++) {
                if ($('#invoiceSelectIcon' + i).hasClass('invoice_not_selected')) {
                    $('#selectAllInvoicesIcon').removeClass('invoice_selected');
                    $('#selectAllInvoicesIcon').removeClass('invoice_not_selected');
                    $('#selectAllInvoicesIcon').addClass('invoice_not_selected');
                    return;
                }
            }

            $('#selectAllInvoicesIcon').removeClass('invoice_selected');
            $('#selectAllInvoicesIcon').removeClass('invoice_not_selected');
            $('#selectAllInvoicesIcon').addClass('invoice_selected');
        }

        function checkBtnsStatus() {
            for (i = 0; i < parseInt($('#countInvoices').html()); i++) {
                if ($('#invoiceSelectIcon' + i).hasClass('invoice_selected')) {
                    $('#rowBtnsPayment').removeClass('variaveis');
                    return;
                }
            }

            $('#rowBtnsPayment').addClass('variaveis');
        }

        function previousFile() {
            if (docSelected == 0) {
                return;
            }

            $('#fileHeader').html(docSelected + '/' + docAmount);
            docSelected--;
            var url = '../faturas/' + docsToBeShowed[docSelected];
            $('#doc').attr('src', url);
        }

        function nextFile() {
            if (docSelected == (docAmount - 1)) {
                return;
            }

            $('#fileHeader').html(docSelected + '/' + docAmount);
            docSelected++;
            var url = '../faturas/' + docsToBeShowed[docSelected];
            $('#doc').attr('src', url);
        }

        function closeDivDocs() {
            $('#overlayShowDocs').hide();
            $('#doc').attr('src', '');
            docsToBeShowed = null;
            docSelected = null;
        }

        function showDivDocs() {
            $('#overlayShowDocs').show();

            var h = $('#divShowDocs').height() - $('#fileSelector').height() - $('#divButton').height();

            $('#divDoc').height(h);
            overlayOn();
        }

        function gerarDadosPagamento() {
            var xml = generateXmlPayment('');

            $.ajax({
                type: "POST",
                url: "lista_faturas_fornecedores.aspx/generatePaymentData",
                data: '{"idUser":"' + localStorage.loga + '","xml":"' + xml + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var ret = parseInt(dados[0]);
                    var msg = dados[1];

                    if (ret < 0) {
                        sweetAlertWarning('FATURAS', msg);
                    }
                    else {
                        swal({
                            title: 'DADOS DE PAGAMENTO',
                            html: msg,
                            customClass: 'dialogWidth',
                            showCancelButton: false,
                            confirmButtonColor: '#007351',
                            confirmButtonText: "OK",
                        }).then(function (isConfirm) {
                            
                        });
                    }
                }
            });
        }

        function pagarFaturas() {
            swal({
                title: "<strong>PAGAMENTOS A FORNECEDORES</strong>",
                text: "Por favor, insira o método de pagamento para todos os pagamentos selecionados!",
                input: 'text',
                showCancelButton: true,
                confirmButtonColor: '#007351',
                cancelButtonColor: '#d33',
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (inputValue) {
                if (inputValue === null || inputValue === false || inputValue === "") {
                    pagarFaturas();
                    return false;
                }

                var xml = generateXmlPayment(inputValue);
                payInvoice(xml);
            });
        }

        function payInvoice(xml) {
            $.ajax({
                type: "POST",
                url: "lista_faturas_fornecedores.aspx/payInvoice",
                data: '{"idUser":"' + localStorage.loga + '","xml":"' + xml + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var ret = parseInt(dados[0]);
                    var msg = dados[1];

                    if (ret < 0) {
                        sweetAlertWarning('FATURAS', msg);
                    }
                    else {
                        getData();
                    }
                }
            });
        }

        function generateXmlPayment(paymentMethod) {
            var xml = "";
            xml += '<PAGAMENTOS>';
            xml += '<FATURAS>';

            for (i = 0; i < parseInt($('#countInvoices').html()); i++) {
                if ($('#invoiceSelectIcon' + i).hasClass('invoice_selected')) {
                    xml += '<ID>' + $('#id' + i).html() + '</ID>';
                }
            }

            xml += '</FATURAS>';

            if (paymentMethod != null && paymentMethod != undefined && paymentMethod != '') {
                xml += '<METODO_PAGAMENTO>' + paymentMethod + '</METODO_PAGAMENTO>';
            }
            
            xml += '</PAGAMENTOS>';

            return xml;
        }
    </script>
</body>

</html>
