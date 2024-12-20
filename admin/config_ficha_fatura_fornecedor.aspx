<%@ Page Language="C#" AutoEventWireup="true" CodeFile="config_ficha_fatura_fornecedor.aspx.cs" Inherits="config_ficha_fatura_fornecedor" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Grilo Car Service Software - Ficha de Fatura de Fornecedor">
    <meta name="author" content="André Lourenço">
    <title>Grilo Car Service Software - Ficha de Fatura de Fornecedor</title>
    <!-- Favicon -->
    <link href="../Img/favicon.ico" rel="icon" type="image/ico">
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
    <!-- Icons -->
    <link href="../general/assets/vendor/nucleo/css/nucleo.css" rel="stylesheet">
    <link href="../general/assets/vendor/@fortawesome/fontawesome-free/css/all.min.css" rel="stylesheet">
    <!-- Argon CSS -->
    <link type="text/css" href="../general/assets/css/argon.css?v=1.0.0" rel="stylesheet">
    <link href="../vendors/sweetalert2/sweetalert2.min.css" rel="stylesheet" />
    <link type="text/css" href="../alertify/css/alertify.min.css" rel="stylesheet" />
    <link type="text/css" href="../alertify/css/themes/default.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.8.0/css/bootstrap-datepicker.css">

    <style>
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
            z-index: 2; /* Specify a stack order in case you're using a different order for other elements */
            cursor: pointer; /* Add a pointer on hover */
        }


        .col-xl-8 {
            max-width: 99%;
            flex: 0 0 99%;
        }

        .pointer {
            cursor: pointer;
        }

        .autocomplete-items {
            position: absolute;
            border: 1px solid #d4d4d4;
            border-bottom: none;
            border-top: none;
            z-index: 99;
            /*position the autocomplete items to be the same width as the container:*/
            top: 100%;
            left: 0;
            right: 0;
        }

            .autocomplete-items div {
                padding: 10px;
                cursor: pointer;
                background-color: #fff;
                border-bottom: 1px solid #d4d4d4;
            }

                .autocomplete-items div:hover {
                    /*when hovering an item:*/
                    background-color: #e9e9e9;
                }

        .autocomplete-active {
            /*when navigating through the items using the arrow keys:*/
            background-color: DodgerBlue !important;
            color: #ffffff;
        }

        .auto_height {
            width: 100%;
        }

        .bg-gradient-primary {
            background: linear-gradient(87deg, #E3101A, #E3101A 100%) !important;
        }

        .bg-gradient-default {
            background: linear-gradient(87deg, #9c080f, #9c080f 100%) !important;
        }

        .btn-default
        {
            color: #fff !important;
            border-color: #9c080f !important;
            background-color: #9c080f !important;
            box-shadow: 0 4px 6px rgba(50, 50, 93, .11), 0 1px 3px rgba(0, 0, 0, .08);
        }
        .btn-default:hover
        {
            color: #fff !important;
            border-color: #9c080f !important; 
            background-color: #9c080f !important;
        }

        .highlight_line {
            background-color: cornsilk;
        }

        .background_white {
            background-color: #FFF;
        }

        .margin_lines_row {
            margin-top: 10px;
            margin-bottom: 10px;
        }

        .dialogWidth {
            width: 75% !important;
            max-width: 100% !important;
        }
    </style>
</head>

<body>
    <!-- Main content -->
    <div class="main-content">

        <div id="overlay"></div>
        <div id="divLoading" class="variaveis">
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

        <!-- Top navbar -->
        <nav class="navbar navbar-top navbar-expand-md navbar-dark" id="navbar-main">
            <div class="container-fluid">
                <!-- Brand -->
                <a class="h4 mb-0 text-white text-uppercase d-none d-lg-inline-block" id="pageTitle">Utilizadores</a>
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
        <div class="header pb-8 pt-5 pt-lg-8 d-flex align-items-center" style="min-height: 200px; background-size: cover; background-position: center top;" id="divInfo">
            <!-- Mask -->
            <span class="mask bg-gradient-primary opacity-8"></span>
            <!-- Header container -->
            <div class="container-fluid d-flex align-items-center">
                <div class="row">
                    <div class="col-lg-12 col-md-10">
                        <h1 class="display-2 text-white" id="divInfoTitle">Pagamento a Fornecedor</h1>
                        <p class="text-white mt-0 mb-5" id="divInfoSubTitle">Crie/Edite um Pagamento a Fornecedor</p>
                    </div>
                </div>
            </div>
        </div>
        <!-- Page content -->
        <div class="container-fluid mt--7">
            <div class="row">

                <div class="col-xl-8 order-xl-1">
                    <div class="card bg-secondary shadow">
                        <div class="card-header bg-white border-0">
                            <div class="row align-items-center">
                                <table style="width: 100%; margin-left: 15px">
                                    <tr>
                                        <td style="width: 90%">
                                            <h3 class="mb-0" id="sectionTitle">Pagamento a Fornecedor</h3>
                                        </td>
                                        <td style="width: 10%; text-align: right">
                                            <img src='../general/assets/img/theme/setae.png' style='width: 30px; height: 30px; cursor: pointer; margin-left: 10px;' alt='Back' title='Back' onclick='retroceder();'/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="card-body" id="divGrelha">
                            <div class="row">
                                <table style="width: 100%; margin-left: 15px;">
                                    <tr>
                                        <td style="width: 90%">
                                            <h6 class="heading-small text-muted mb-4 pointer" onclick="showHideProvider();">FORNECEDOR</h6>
                                        </td>
                                        <td style="width: 10%; text-align: right">
                                            <img src='../Img/search_icon.png' style='width: 30px; height: 30px; cursor: pointer; margin-left: 10px;' alt='Pesquisar Fornecedor' title='Pesquisar Fornecedor' onclick='searchProvider();'/>
                                        </td>
                                    </tr>
                                </table>
                            </div>                            

                            <div class="row" id="providerNameRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtProviderName">Nome</label>
                                        <input type="text" id="txtProviderName" class="form-control form-control-alternative" placeholder="Nome do Fornecedor">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="providerAddressRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtProviderAddress">Morada</label>
                                        <input type="text" id="txtProviderAddress" class="form-control form-control-alternative" placeholder="Morada do Fornecedor">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="providerZipCodeCityRow">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtProviderZipCode">Código Postal</label>
                                        <input type="text" id="txtProviderZipCode" class="form-control form-control-alternative" placeholder="Código Postal do Fornecedor">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtProviderCity">Localidade</label>
                                        <input type="text" id="txtProviderCity" class="form-control form-control-alternative" placeholder="Localidade do Fornecedor">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="providerEmailRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtProviderEmail">Email</label>
                                        <input type="email" id="txtProviderEmail" class="form-control form-control-alternative" placeholder="Email do Fornecedor">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="providerFiscalDataRow">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtProviderNIF">NIF</label>
                                        <input type="text" id="txtProviderNIF" class="form-control form-control-alternative" placeholder="NIF" onfocusout="checkProvider(false);">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtProviderNumDiasPagamento">Nº Dias Pagamento</label>
                                        <input type="number" id="txtProviderNumDiasPagamento" class="form-control form-control-alternative" placeholder="Nº Dias Pagamento">
                                    </div>
                                </div>
                                <div class="col-md-5">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtProviderIban">IBAN</label>
                                        <input type="text" id="txtProviderIban" class="form-control form-control-alternative" placeholder="IBAN do Fornecedor" onfocusout="validateIBAN(false);">
                                    </div>
                                </div>
                            </div>

                            <div class="row variaveis" id="providerNotesRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtNotes">Notas</label>
                                        <textarea type='text' id='txtProviderNotes' class='form-control form-control-alternative auto_height' oninput='auto_height(this)' placeholder='Notas'></textarea>
                                    </div>
                                </div>
                            </div>

                            <h6 class="heading-small text-muted mb-4 pointer" onclick="showHideInvoiceData();">DADOS DA FATURA</h6>

                            <div class="row" id="invoiceNumberValueRow">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtInvoiceNumber">Nº Fatura</label>
                                        <input type="text" id="txtInvoiceNumber" class="form-control form-control-alternative" placeholder="Nº da Fatura">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtInvoiceValue">Valor</label>
                                        <input type="number" id="txtInvoiceValue" class="form-control form-control-alternative" placeholder="Valor">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="invoiceDatesRow">
                                <div class="col-md-6">
                                    <div class="form-group" id="invoicedatepicker">
                                        <label class="form-control-label" for="txtInvoiceDate">Data da Fatura</label>
                                        <input type="text" id="txtInvoiceDate" class="form-control form-control-alternative" placeholder="Data da Fatura">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group" id="duedatepicker">
                                        <label class="form-control-label" for="txtInvoiceDueDate">Data de Vencimento</label>
                                        <input type="text" id="txtInvoiceDueDate" class="form-control form-control-alternative" placeholder="Data de Vencimento">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="invoiceDescriptionRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtInvoiceDescription">Descrição</label>
                                        <textarea type="text" id="txtInvoiceDescription" class="form-control form-control-alternative auto_height" oninput="auto_height(this)" placeholder="Descrição da Fatura"></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="invoiceFileUploadRow">
                                <div class="col-md-12">
                                    <form id="formUploadProviders" runat="server">
                                        <table style="width:100%; height: auto;">
                                            <tr>
                                                <td style="width: 50%; max-width: 50% !important; text-align: center;">
                                                    <button type='button' style="width:100%; height: 100%;" class='btn btn-sm btn-primary' id='buttonFileUpload' onclick='simulateClickOnFileUploadButton();' runat='server'>Carregar Fatura</button>
                                                </td>
                                                <td style="width: 50%; max-width: 50% !important; text-align: center;">
                                                    <p class='text-danger' id='fileUploadedName' runat='server'><br />Nenhum ficheiro selecionado</p>
                                                    <asp:Button runat="server" Text="Carregar Fatura para o Sistema" ID="uploadButton" OnClick="Upload_Click" CssClass="btn btn-sm btn-primary variaveis" />
                                                </td>
                                            </tr>
                                        </table>
                                        <div class="variaveis">
                                            <p class='text-danger' id='uploadFileDanger' runat='server'></p>
                                            <p class='text-sucess' id='uploadFileSuccess' runat='server'></p>
                                            <asp:FileUpload ID="FileUploadControl" runat="server" CssClass="variaveis" />
                                            <asp:TextBox ID="userID" runat="server" CssClass="variaveis" />
                                            <asp:TextBox ID="invoiceID" runat="server" CssClass="variaveis" />
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <div class="row" style="margin-top: 20px;">
                                <div class="col-md-12">
                                    <input type="button" class="btn btn-default" onclick="saveData();" value="Guardar alterações" style="width: 100%;"/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <footer class="footer">
                <div class="row align-items-center justify-content-xl-between">
                    <div class="col-xl-6">
                        <div class="copyright text-center text-xl-left text-muted">
                            <%--&copy; 2019, Plataforma desenvolvida por <a href="http://www.mbsolutions.pt" class="font-weight-bold ml-1" target="_blank">MBSolutions</a>--%>
                        </div>
                    </div>
                </div>
            </footer>

            <div id="hiddenVals" class="variaveis">
                <input id="txtAux" runat="server" type="text" class="variaveis" />
                <input id="txtAuxDefaultInvoiceDate" runat="server" type="text" class="variaveis" />
                <input id="txtAuxDefaultInvoiceDueDate" runat="server" type="text" class="variaveis" />
            </div>
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
        var idProviderSelected = "";
        var tableProviders = "";
        var providerIDSelected = "";
        var providerDialogOpen = false;
        var administrador;
        var anyfileuploadstring = "";
        var isNIFDialogOpen = false;
        var isIBANDialogOpen = false;

        $(document).ready(function () {
            loga();
            setAltura();
            getProvidersList();

            anyfileuploadstring = $('#fileUploadedName').html();

            $('#FileUploadControl').change(function () {
                var path = $(this).val();
                if (path != '' && path != null) {
                    var q = path.substring(path.lastIndexOf('\\') + 1);
                    $('#fileUploadedName').html('<br />' + q);
                }
                else {
                    $('#fileUploadedName').html(anyfileuploadstring);
                }
            });

            if ($('#uploadFileSuccess').html() != '' && $('#uploadFileDanger').html() == '' && $('#fileUploadedName').html() == anyfileuploadstring) {
                loadUrl("lista_faturas_fornecedores.aspx");
            }
        });

        $(window).resize(function () {
            setAltura();
        });

        $(document).keypress(function (e) {
            if (e.which == 13) {
                checkFocus();
            }
        });

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
                    getData();
                }
            });
        }

        function addMonths(numOfMonths, date) {
            date.setMonth(date.getMonth() + numOfMonths);

            return date;
        }

        function getStrDate(date) {
            var dateStr = '';
            var day = parseInt(date.getDate());
            var month = parseInt(date.getMonth()) + 1;
            var year = parseInt(date.getFullYear());

            if (day < 10) {
                dateStr += '0' + day;
            }
            else {
                dateStr += '' + day;
            }

            if (month < 10) {
                dateStr += '/0' + month;
            }
            else {
                dateStr += '/' + month;
            }

            dateStr += '/' + year;

            return dateStr;
        }

        function setDatePicker(date, dueDateStr) {
            var invoiceDate;
            var dueDate;
            var dateSplit;
            var dueDateSplit;
            var dateToBeUsed = date == '' ? $('#txtAuxDefaultInvoiceDate').val() : date;
            var dueDateToBeUsed = dueDateStr == '' ? $('#txtAuxDefaultInvoiceDueDate').val() : dueDateStr;

            dateSplit = dateToBeUsed.split('/');
            dueDateSplit = dueDateToBeUsed.split('/');

            invoiceDate = new Date(dateSplit[2], dateSplit[1] - 1, dateSplit[0]);
            dueDate = new Date(dueDateSplit[2], dueDateSplit[1] - 1, dueDateSplit[0]);

            $('#txtInvoiceDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtInvoiceDate').datepicker('setDate', invoiceDate).on('changeDate', function (e) {
                checkDueDate();
            });
            $('#txtInvoiceDate').val(dateToBeUsed);

            $('#txtInvoiceDueDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtInvoiceDueDate').datepicker('setDate', dueDate);
            $('#txtInvoiceDueDate').val(dueDateToBeUsed);
        }

        function setAltura() {
            $("#fraContent").height($(window).height());
        }

        function defineTablesMaxHeight() {
            var windowHeight = $(window).height();
            var divInfoHeight = $('#divInfo').height();
            var navbarHeight = $('#navbar-main').height();
            var maxHeight = windowHeight - divInfoHeight - navbarHeight - 200;

            $('#divGrelha').css({ "maxHeight": maxHeight + "px" });
        }

        function checkDueDate() {
            var date = $('#txtInvoiceDate').val();
            var numDias = $('#txtProviderNumDiasPagamento').val();

            if (date != '' && date != null && date != undefined &&
                numDias != '' && numDias != null && date != numDias) {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/getDueDateCalculation",
                    data: '{"invoiceDate":"' + date + '","paymentDays":"' + numDias + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        if (res.d != '') {
                            $('#txtInvoiceDueDate').val(res.d);
                        }
                    }
                });
            }
        }

        function getProvidersList() {
            var search = "";
            var open = "0";

            if (providerDialogOpen) {
                search = $('#providerSearchBar').val().trim();
                open = "1";
            }

            $.ajax({
                type: "POST",
                url: "config_ficha_fatura_fornecedor.aspx/getProvidersList",
                data: '{"search":"' + search + '","dialogOpen":"' + open + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    if (providerDialogOpen) {
                        $('#divTableProviders').html(res.d);
                    }
                    else {
                        tableProviders = res.d;
                    }
                }
            });
        }

        function getProviderData(nif, enter) {
            var id = nif == '' ? providerIDSelected : '0';
            $.ajax({
                type: "POST",
                url: "config_ficha_fatura_fornecedor.aspx/getProviderData",
                data: '{"id":"' + id + '","contribuinte":"' + nif + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');

                    var nome = dados[0];
                    var morada = dados[1]
                    var codpostal = dados[2];
                    var localidade = dados[3];
                    var nif = dados[4];
                    var iban = dados[5];
                    var email = dados[6];
                    var notas = dados[7];
                    var numdiaspagamento = dados[8];

                    $('#txtProviderName').val(nome);
                    $('#txtProviderAddress').val(morada);
                    $('#txtProviderZipCode').val(codpostal);
                    $('#txtProviderCity').val(localidade);
                    $('#txtProviderNIF').val(nif);
                    $('#txtProviderIban').val(iban);
                    $('#txtProviderNumDiasPagamento').val(numdiaspagamento);
                    $('#txtProviderNotes').val(notas);
                    $('#txtProviderEmail').val(email);

                    providerIDSelected = "";

                    if (enter) {
                        $('#txtProviderNumDiasPagamento').focus();
                    }
                }
            });
        }

        function searchProvider() {
            providerDialogOpen = true;

            swal({
                title: "<strong>FORNECEDORES</strong>",
                html: tableProviders,
                customClass: 'dialogWidth',
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (isConfirm) {
                providerDialogOpen = false;

                if (isConfirm) {
                    getProviderData('', false);
                }
            });
        }

        function selectProviderRow(id, i) {
            if (id == providerIDSelected) {
                providerIDSelected = "0";
                $('#providerLine' + i).removeClass('highlight_line');
                return;
            }

            var total = parseInt($('#countProviders').html());

            for (let x = 0; x < total; x++) {
                $('#providerLine' + x).removeClass('highlight_line');
            }

            providerIDSelected = id;
            $('#providerLine' + i).addClass('highlight_line');
        }

        function getData() {
            loadingOn('A carregar dados!<br />Por favor aguarde...');
            var id = $('#txtAux').val();
            if (id != null && id != 'null' && id != '') {
                $.ajax({
                    type: "POST",
                    url: "config_ficha_fatura_fornecedor.aspx/getData",
                    data: '{"id":"' + id + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var dados = res.d.split('<#SEP#>');

                        // Prepara o retorno dos dados
                        var provider = dados[0];
                        var provider_address = dados[1];
                        var provider_city = dados[2];
                        var provider_zipcode = dados[3];
                        var provider_nif = dados[4];
                        var provider_iban = dados[5];
                        var provider_notes = dados[6];
                        var number = dados[7];
                        var invoice_date = dados[8];
                        var invoice_due_date = dados[9];
                        var value = dados[10];
                        var notes = dados[11];
                        var provider_email = dados[12];
                        var provider_numdiaspagamento = dados[13];

                        $('#txtProviderName').val(provider);
                        $('#txtProviderAddress').val(provider_address);
                        $('#txtProviderZipCode').val(provider_zipcode);
                        $('#txtProviderCity').val(provider_city);
                        $('#txtProviderEmail').val(provider_email);
                        $('#txtProviderNIF').val(provider_nif);
                        $('#txtProviderIban').val(provider_iban);
                        $('#txtProviderNotes').val(provider_notes);
                        $('#txtInvoiceNumber').val(number);
                        $('#txtInvoiceValue').val(value);
                        $('#txtInvoiceDescription').val(notes);
                        $('#txtProviderNumDiasPagamento').val(provider_numdiaspagamento);

                        setDatePicker(invoice_date, invoice_due_date);
                    }
                });
            }
            else {
                $('#txtProviderName').val('');
                $('#txtProviderAddress').val('');
                $('#txtProviderZipCode').val('');
                $('#txtProviderCity').val('');
                $('#txtProviderEmail').val('');
                $('#txtProviderNIF').val('');
                $('#txtProviderIban').val('');
                $('#txtProviderNotes').val('');
                $('#txtInvoiceNumber').val('');
                $('#txtInvoiceValue').val('0.00');
                $('#txtInvoiceDescription').val('');
                $('#txtProviderNumDiasPagamento').val('30');
                setDatePicker('', '');
            }

            loadingOff();
        }

        function saveData() {
            var id = $('#txtAux').val();
            var xml = '';
            var providerName = $('#txtProviderName').val();
            var providerAddress = $('#txtProviderAddress').val();
            var providerZipCode = $('#txtProviderZipCode').val();
            var providerCity = $('#txtProviderCity').val();
            var providerEmail = $('#txtProviderEmail').val();
            var providerNIF = $('#txtProviderNIF').val();
            var providerIBAN = $('#txtProviderIban').val();
            var providerNotes = $('#txtProviderNotes').val();
            var number = $('#txtInvoiceNumber').val();
            var value = $('#txtInvoiceValue').val();
            var date = $('#txtInvoiceDate').val();
            var dueDate = $('#txtInvoiceDueDate').val();
            var description = $('#txtInvoiceDescription').val();
            var numdiaspagamento = $('#txtProviderNumDiasPagamento').val();

            if (id == null || id == 'null' || id == '') {
                id = '0';
            }

            if (providerName == '' || providerName == null || providerName == undefined) {
                sweetAlertWarning('Nome do Fornecedor', 'Por favor indique o nome do fornecedor');
                return;
            }
            else if (providerAddress == '' || providerAddress == null || providerAddress == undefined) {
                sweetAlertWarning('Morada do Fornecedor', 'Por favor indique a morada do fornecedor');
                return;
            }
            else if (providerZipCode == '' || providerZipCode == null || providerZipCode == undefined) {
                sweetAlertWarning('Código Postal do Fornecedor', 'Por favor indique o código postal do fornecedor');
                return;
            }
            else if (providerCity == '' || providerCity == null || providerCity == undefined) {
                sweetAlertWarning('Localidade do Fornecedor', 'Por favor indique a localidade do fornecedor');
                return;
            }
            else if (providerEmail == '' || providerEmail == null || providerEmail == undefined) {
                sweetAlertWarning('Email do Fornecedor', 'Por favor indique o email do fornecedor');
                return;
            }
            else if (providerNIF == '' || providerNIF == null || providerNIF == undefined) {
                sweetAlertWarning('NIF do Fornecedor', 'Por favor indique o NIF do fornecedor');
                return;
            }
            else if (providerIBAN == '' || providerIBAN == null || providerIBAN == undefined) {
                sweetAlertWarning('IBAN do Fornecedor', 'Por favor indique o IBAN do fornecedor');
                return;
            }
            else if (number == '' || number == null || number == undefined) {
                sweetAlertWarning('Nº da Fatura', 'Por favor indique o nº da fatura');
                return;
            }
            else if (value == '' || value == null || value == undefined || value.length === 0) {
                sweetAlertWarning('Valor da Fatura', 'Por favor indique o valor da fatura');
                return;
            }
            else if (date == '' || date == null || date == undefined) {
                sweetAlertWarning('Data da Fatura', 'Por favor indique a data da fatura');
                return;
            }
            else if (dueDate == '' || dueDate == null || dueDate == undefined) {
                sweetAlertWarning('Data de Vencimento da Fatura', 'Por favor indique a data de vencimento da fatura');
                return;
            }
            else if (numdiaspagamento == '' || numdiaspagamento == null || numdiaspagamento == undefined) {
                numdiaspagamento = '30';
            }

            xml += '<FATURA>';
            xml += '<ID>' + id + '</ID>';
            xml += '<NUMERO>' + number + '</NUMERO>';
            xml += '<DATA_VENCIMENTO>' + dueDate + '</DATA_VENCIMENTO>';
            xml += '<DATA>' + date + '</DATA>';
            xml += '<DESCRICAO>' + description + '</DESCRICAO>';
            xml += '<VALOR>' + value + '</VALOR>';
            xml += '<FORNECEDOR>';
            xml += '<NOME>' + providerName + '</NOME>';
            xml += '<MORADA>' + providerAddress + '</MORADA>';
            xml += '<CODPOSTAL>' + providerZipCode + '</CODPOSTAL>';
            xml += '<LOCALIDADE>' + providerCity + '</LOCALIDADE>';
            xml += '<NIF>' + providerNIF + '</NIF>';
            xml += '<EMAIL>' + providerEmail + '</EMAIL>';
            xml += '<IBAN>' + providerIBAN + '</IBAN>';
            xml += '<NOTES>' + providerNotes + '</NOTES>';
            xml += '<NUMDIASPAGAMENTO>' + numdiaspagamento + '</NUMDIASPAGAMENTO>';
            xml += '</FORNECEDOR>';
            xml += '</FATURA>';

            $.ajax({
                type: "POST",
                url: "config_ficha_fatura_fornecedor.aspx/saveData",
                data: '{"idUser":"' + localStorage.loga + '","xml":"' + xml + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');

                    if (parseInt(dados[0]) < 0) {
                        sweetAlertError(title, dados[1]);
                    }
                    else {
                        if ($('#fileUploadedName').html() != anyfileuploadstring) {
                            $('#invoiceID').val(dados[0]);
                            $('#uploadButton').click();
                        }
                        else {
                            loadUrl('lista_faturas_fornecedores.aspx');
                        }
                    }
                }
            });
        }


        function loadUrl(url) {
            window.location = url;
        }

        function retroceder() {
            swal({
                title: "SAIR",
                text: "Tem a certeza que pretende sair? Todos os dados serão perdidos.",
                type: 'question',
                showCancelButton: true,
                confirmButtonColor: '#007351',
                cancelButtonColor: '#d33',
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (isConfirm) {
                if (isConfirm) {
                    loadUrl('config_lista_faturas_fornecedores.aspx');
                }
            });
        }

        function confirmSave() {
            swal({
                title: "GUARDAR",
                text: "Tem a certeza que deseja guardar a informação?",
                type: "question",
                showCancelButton: true,
                confirmButtonColor: '#007351',
                cancelButtonColor: '#d33',
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (isConfirm) {
                if (isConfirm) {
                    saveData();
                }
            });
        }

        function checkProvider(enter) {
            var text = $('#txtProviderNIF').val();

            if (text != '' && text != null && text != undefined) {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/checkExistentProvider",
                    data: '{"text":"' + text + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        if (parseInt(res.d) > 0) {
                            //var title = "FORNECEDOR";
                            //var text = 'O fornecedor com o NIF inserido já existe no sistema!';
                            //sweetAlertInfo(title, text);
                            getProviderData(text, enter);
                        }
                        else {
                            validarnif(enter);
                        }
                    }
                });
            }
        }

        function validarnif(enter) {
            var nif = $("#txtProviderNIF").val();

            $.ajax({
                type: "POST",
                url: "index.aspx/validateNIF",
                data: '{"nif":"' + nif + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var ret = dados[0];
                    var msg = dados[1];

                    if (parseInt(ret) <= 0) {
                        sweetAlertError("FORNECEDOR", msg);
                    }
                    else {
                        if (dados.length > 2) {
                            var nome = dados[2];
                            var morada = dados[3];
                            var codpostal = dados[4];
                            var localidade = dados[5];
                            var email = dados[6];
                            var notas = dados[7];

                            $('#txtProviderNumDiasPagamento').val('30');
                            $('#txtProviderName').val(nome);
                            $('#txtProviderAddress').val(morada);
                            $('#txtProviderZipCode').val(codpostal);
                            $('#txtProviderCity').val(localidade);
                            $('#txtProviderEmail').val(email);
                            $('#txtProviderNotes').val(notas);
                        }

                        if (!isNIFDialogOpen) {
                            isNIFDialogOpen = true;

                            swal({
                                title: "FORNECEDOR",
                                text: msg,
                                type: "info"
                            }).then(function () {
                                if (enter) {
                                    $('#txtProviderNumDiasPagamento').focus();
                                }

                                setTimeout(
                                    function () {
                                        isNIFDialogOpen = false;
                                    }, 500);
                            });
                        }
                    }
                }
            });
        }

        function validateIBAN(enter) {
            var iban = $("#txtProviderIban").val();

            $.ajax({
                type: "POST",
                url: "index.aspx/validateIBAN",
                data: '{"iban":"' + iban + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var ret = dados[0];
                    var msg = dados[1];

                    if (parseInt(ret) <= 0) {
                        sweetAlertError("FORNECEDOR", msg);
                    }
                    else {
                        $('#txtInvoiceNumber').focus();
                        //if (!isIBANDialogOpen) {
                        //    isIBANDialogOpen = true;

                        //    swal({
                        //        title: "FORNECEDOR",
                        //        text: msg,
                        //        type: "info"
                        //    }).then(function () {
                        //        if (enter) {
                                    
                        //        }

                        //        setTimeout(
                        //            function () {
                        //                isIBANDialogOpen = false;
                        //            }, 500);
                        //    });
                        //}
                    }
                }
            });
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
            overlayOff();
            document.getElementById("overlay").style.display = "block";
        }

        function overlayOff() {
            document.getElementById("overlay").style.display = "none";
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

        function showHideProvider() {
            if ($('#providerNameRow').is(":visible")) {
                $('#providerNameRow').fadeOut();
                $('#providerAddressRow').fadeOut();
                $('#providerZipCodeCityRow').fadeOut();
                $('#providerEmailRow').fadeOut();
                $('#providerFiscalDataRow').fadeOut();
                $('#providerNotesRow').fadeOut();
            }
            else {
                $('#providerNameRow').fadeIn();
                $('#providerAddressRow').fadeIn();
                $('#providerZipCodeCityRow').fadeIn();
                $('#providerEmailRow').fadeIn();
                $('#providerFiscalDataRow').fadeIn();
            }
        }

        function showHideInvoiceData() {
            if ($('#invoiceNumberValueRow').is(":visible")) {
                $('#invoiceNumberValueRow').fadeOut();
                $('#invoiceDatesRow').fadeOut();
                $('#invoiceDescriptionRow').fadeOut();
                $('#invoiceFileUploadRow').fadeOut();
            }
            else {
                $('#invoiceNumberValueRow').fadeIn();
                $('#invoiceDatesRow').fadeIn();
                $('#invoiceDescriptionRow').fadeIn();
                $('#invoiceFileUploadRow').fadeIn();
            }
        }

        function auto_height(elem) {  /* javascript */
            elem.style.height = "1px";
            elem.style.height = (elem.scrollHeight) + "px";
        }

        function checkFocus() {
            if ($("#providersSearchBar").is(":focus")) {
                getProvidersList();
                return;
            }

            if ($("#txtPesquisa").is(":focus")) {
                getData();
                return;
            }

            if ($("#txtProviderNIF").is(":focus")) {
                checkProvider(true);
                return;
            }

            if ($("#txtProviderIban").is(":focus")) {
                validateIBAN(true);
                return;
            }

            if ($("#txtProviderName").is(":focus")) {
                $('#txtProviderAddress').focus();
                return;
            }

            if ($("#txtProviderAddress").is(":focus")) {
                $('#txtProviderZipCode').focus();
                return;
            }

            if ($("#txtProviderZipCode").is(":focus")) {
                $('#txtProviderCity').focus();
                return;
            }

            if ($("#txtProviderCity").is(":focus")) {
                $('#txtProviderEmail').focus();
                return;
            }

            if ($("#txtProviderEmail").is(":focus")) {
                $('#txtProviderNIF').focus();
                return;
            }

            if ($("#txtProviderNumDiasPagamento").is(":focus")) {
                $('#txtProviderIban').focus();
                return;
            }

            if ($("#txtInvoiceNumber").is(":focus")) {
                $('#txtInvoiceValue').focus();
                return;
            }

            if ($("#txtInvoiceValue").is(":focus")) {
                $('#txtInvoiceDate').focus();
                return;
            }

            if ($("#txtInvoiceDate").is(":focus")) {
                $('#txtInvoiceDueDate').focus();
                return;
            }

            if ($("#txtInvoiceDueDate").is(":focus")) {
                $('#txtInvoiceDescription').focus();
                return;
            }

            if ($("#txtInvoiceDescription").is(":focus")) {
                $('#txtInvoiceDescription').blur();
                return;
            }
        }

        function simulateClickOnFileUploadButton() {
            $('#FileUploadControl').click();
        }
    </script>
</body>

</html>
