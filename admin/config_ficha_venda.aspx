<%@ Page Language="C#" AutoEventWireup="true" CodeFile="config_ficha_venda.aspx.cs" Inherits="config_ficha_venda" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Grilo Car Service Software - Ficha de Venda">
    <meta name="author" content="André Lourenço">
    <title>Grilo Car Service Software - Ficha de Venda</title>
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
                <a class="h4 mb-0 text-white text-uppercase d-none d-lg-inline-block" id="pageTitle">Vendas</a>
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
                        <h1 class="display-2 text-white" id="divInfoTitle">Vendas</h1>
                        <p class="text-white mt-0 mb-5" id="divInfoSubTitle">Crie / Edite as vendas</p>
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
                                            <h3 class="mb-0" id="sectionTitle">Vendas</h3>
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
                                            <h6 class="heading-small text-muted mb-4 pointer" onclick="showHideCustomer();">CLIENTE</h6>
                                        </td>
                                        <td style="width: 10%; text-align: right">
                                            <img src='../Img/search_icon.png' style='width: 30px; height: 30px; cursor: pointer; margin-left: 10px;' alt='Pesquisar Cliente' title='Pesquisar Cliente' onclick='searchCustomer();'/>
                                        </td>
                                    </tr>
                                </table>
                            </div>                            

                            <div class="row" id="customerNameRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCustomerName">Nome</label>
                                        <input type="text" id="txtCustomerName" class="form-control form-control-alternative" placeholder="Nome do Cliente">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="customerAddressRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCustomerAddress">Morada</label>
                                        <input type="text" id="txtCustomerAddress" class="form-control form-control-alternative" placeholder="Morada do Cliente">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="customerZipCodeCityRow">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCustomerZipCode">Código Postal</label>
                                        <input type="text" id="txtCustomerZipCode" class="form-control form-control-alternative" placeholder="Código Postal do Cliente">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCustomerCity">Localidade</label>
                                        <input type="text" id="txtCustomerCity" class="form-control form-control-alternative" placeholder="Localidade do Cliente">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="customerNIFRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCustomerNIF">NIF</label>
                                        <input type="text" id="txtCustomerNIF" class="form-control form-control-alternative" placeholder="NIF do Cliente" onfocusout="checkCustomer();">
                                    </div>
                                </div>
                            </div>

                            <h6 class="heading-small text-muted mb-4 pointer" onclick="showHideData();" id="estimate_maintenance_title">DADOS DA VENDA</h6>

                            <div class="row" id="numberDatesRow">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtNumber">Nº Fatura</label>
                                        <input type="text" id="txtNumber" class="form-control form-control-alternative" placeholder="Nº da Fatura">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group" id="datepicker">
                                        <label class="form-control-label" for="txtDate">Data</label>
                                        <input type="text" id="txtDate" class="form-control form-control-alternative" placeholder="Data">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group" id="duedatepicker">
                                        <label class="form-control-label" for="txtDueDate">Data de Vencimento</label>
                                        <input type="text" id="txtDueDate" class="form-control form-control-alternative" placeholder="Data de Vencimento">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="payDataRow">
                                <div class="col-md-6">
                                    <div class="custom-control custom-control-alternative custom-checkbox">
                                        <input class="custom-control-input" id="chkPayed" type="checkbox" onclick="onChangeCheckboxPayed();">
                                        <label class="custom-control-label" for="chkPayed">
                                            <span class="text-muted">Paga</span>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtPaymentMethod">Método de Pagamento</label>
                                        <textarea type="text" id="txtPaymentMethod" class="form-control form-control-alternative auto_height" oninput="auto_height(this)" placeholder="Método de Pagamento da Fatura"></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="descriptionRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtDescription">Descrição</label>
                                        <textarea type="text" id="txtDescription" class="form-control form-control-alternative auto_height" oninput="auto_height(this)" placeholder="Descrição"></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="valuesRow">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtTotalValue">Valor Total</label>
                                        <input type="number" id="txtTotalValue" class="form-control form-control-alternative" placeholder="Valor Total" disabled>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtIvaValue">Valor IVA</label>
                                        <input type="number" id="txtIvaValue" class="form-control form-control-alternative" placeholder="Valor IVA" disabled>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <table style="width: 100%; margin-left: 15px;">
                                    <tr>
                                        <td style="width: 90%">
                                            <h6 class="heading-small text-muted mb-4 pointer" onclick="showHideLinesData();">LINHAS</h6>
                                        </td>
                                        <td style="width: 10%; text-align: right">
                                            <img src='../Img/plus_icon.png' style='width: 30px; height: 30px; cursor: pointer; margin-left: 10px;' alt='Adicionar Linha' title='Adicionar Linha' onclick='openNewLineDialog(-1);'/>
                                        </td>
                                    </tr>
                                </table>
                            </div>

                            <div class="row" id="linesHeader" style="margin-bottom: 20px;">
                                <div class="col-md-6" style="font-weight: bold">
                                    DESCRIÇÃO
                                </div>
                                <div class="col-md-3" style="font-weight: bold">
                                    VALOR SEM IVA
                                </div>
                                <div class="col-md-3" style="font-weight: bold">
                                    IVA
                                </div>
                            </div>

                            <div id="divLines" style="padding: 0px !important; margin-bottom: 20px;">

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
                <input id="txtAuxNumeroDiasPagamento" runat="server" type="text" class="variaveis" />
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
        var idCustomerSelected = "";
        var tableCustomers = "";
        var customerIDSelected = "";
        var customerDialogOpen = false;
        var newLine = "";
        var newLineDescription = "";
        var newLineValue = "";
        var newLineValueIVA = "";
        var newLineTemplate = "";
        var linesInserted = 0;
        var administrador;

        $(document).ready(function () {
            loga();
            setAltura();
            getCustomersList();
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

            invoiceDate = new Date(dateSplit[2], dateSplit[1]-1, dateSplit[0]);
            dueDate = new Date(dueDateSplit[2], dueDateSplit[1]-1, dueDateSplit[0]);

            $('#txtDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtDate').datepicker('setDate', invoiceDate).on('changeDate', function (e) {
                checkDueDate();
            });
            $('#txtDate').val(dateToBeUsed);

            $('#txtDueDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtDueDate').datepicker('setDate', dueDate);
            $('#txtDueDate').val(dueDateToBeUsed);
        }

        function onChangeCheckboxPayed() {
            var checkbox = document.getElementById('chkPayed');
            $('#txtPaymentMethod').prop('disabled', !checkbox.checked);
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

        function getCustomersList() {
            var search = "";
            var open = "0";

            if (customerDialogOpen) {
                search = $('#customerSearchBar').val().trim();
                open = "1";
            }

            $.ajax({
                type: "POST",
                url: "config_ficha_venda.aspx/getCustomersList",
                data: '{"search":"' + search + '","dialogOpen":"' + open + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    if (customerDialogOpen) {
                        $('#divTableCustomers').html(res.d);
                    }
                    else {
                        tableCustomers = res.d;
                    }
                }
            });
        }

        function getCustomerData(nif) {
            $.ajax({
                type: "POST",
                url: "config_ficha_venda.aspx/getCustomerData",
                data: '{"id":"' + customerIDSelected + '","nif":"' + nif + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');

                    var nome = dados[0];
                    var morada = dados[1]
                    var codpostal = dados[2];
                    var localidade = dados[3];
                    var nif = dados[4];

                    $('#txtCustomerName').val(nome);
                    $('#txtCustomerAddress').val(morada);
                    $('#txtCustomerZipCode').val(codpostal);
                    $('#txtCustomerCity').val(localidade);
                    $('#txtCustomerNIF').val(nif);

                    customerIDSelected = "";
                    $('#txtCarBrand').focus();
                }
            });
        }

        function searchCustomer() {
            customerDialogOpen = true;

            swal({
                title: "<strong>CLIENTES</strong>",
                html: tableCustomers,
                customClass: 'dialogWidth',
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (isConfirm) {
                customerDialogOpen = false;

                if (isConfirm) {
                    getCustomerData('');
                }
            });
        }

        function selectCustomerRow(id, i) {
            if (id == customerIDSelected) {
                customerIDSelected = "0";
                $('#customerLine' + i).removeClass('highlight_line');
                return;
            }

            var total = parseInt($('#countCustomers').html());

            for (let x = 0; x < total; x++) {
                $('#customerLine' + x).removeClass('highlight_line');
            }

            customerIDSelected = id;
            $('#customerLine' + i).addClass('highlight_line');
        }

        function openNewLineDialog(line) {
            var template = newLine;

            if (line < 0) {
                template = template.replace('[txtNewLineDescription_value]', newLineDescription).replace('[txtNewLineValue_value]', newLineValue);

                if (newLineValueIVA != '') {
                    var ivaToReplace = "<option value='" + newLineValueIVA + "'>" + newLineValueIVA + "%</option>";
                    var selectedIva = "<option value='" + newLineValueIVA + "' selected>" + newLineValueIVA + "%</option>";

                    template = template.replace(ivaToReplace, selectedIva);
                }
            }
            else {
                var desc = $('#div' + line + 'Description').html();
                var iva = $('#div' + line + 'IVA').html().replace('%', '');
                var val = $('#div' + line + 'Value').html().replace('€', '');
                var ivaToReplace = "<option value='" + iva + "'>" + iva + "%</option>";
                var selectedIva = "<option value='" + iva + "' selected>" + iva + "%</option>";

                template = template.replace('[txtNewLineDescription_value]', desc).replace('[txtNewLineValue_value]', val).replace(ivaToReplace, selectedIva);
            }

            swal({
                title: "<strong>INSERIR NOVA LINHA</strong>",
                html: template,
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (isConfirm) {
                if (isConfirm) {
                    getValues(line);
                }
            });
        }

        function getValues(line) {
            newLineValueIVA = $('#valueIVA option:selected').val();
            newLineDescription = $('#txtNewLineDescription').val();
            newLineValue = $('#txtNewLineValue').val();

            if (newLineDescription.trim() == '' || isNaN(newLineValue) || newLineValue.trim() == '') {
                openNewLineDialog(line);
                return;
            }

            if (line < 0) {
                getNewLineValues();
            }
            else {
                getEditLineValues(line);
            }
        }

        function getNewLineValues() {
            var lineToBeInserted = $('#divLines').html() + newLineTemplate.replace('[NEWLINE_DESCRIPTION]', newLineDescription).replace('[NEWLINE_VALUE]', parseFloat(newLineValue).toFixed(2).toString() + '€').replace('[NEWLINE_IVA]', parseFloat(newLineValueIVA).toFixed(2).toString() + '%');
            $('#divLines').html(lineToBeInserted);

            $('#div' + linesInserted + 'Description').html(newLineDescription);
            $('#div' + linesInserted + 'Value').html(newLineValue + '€');
            $('#div' + linesInserted + 'IVA').html(newLineValueIVA + '%');

            linesInserted = linesInserted + 1;

            newLineTemplate = "<div class='row pointer margin_lines_row" + (linesInserted % 2 != 0 ? " background_white " : "") + "' id='line" + linesInserted + "' ondblclick='openNewLineDialog(" + linesInserted + ");'>"
                + "<div class='variaveis' id='div" + linesInserted + "Id'>0</div>"
                + "<div class='col-md-6' id='div" + linesInserted + "Description'>[NEWLINE_DESCRIPTION]</div>"
                + "<div class='col-md-3' id='div" + linesInserted + "Value'>[NEWLINE_VALUE]</div>"
                + "<div class='col-md-3' id='div" + linesInserted + "IVA'>[NEWLINE_IVA]</div>"
                + "</div>";

            var tot = parseFloat(newLineValue) * (1 + (0.01 * parseFloat(newLineValueIVA)));
            var iva = parseFloat(newLineValue) * (0.01 * parseFloat(newLineValueIVA));

            tot += parseFloat($('#txtTotalValue').val());
            iva += parseFloat($('#txtIvaValue').val());

            $('#txtTotalValue').val(tot.toFixed(2).toString());
            $('#txtIvaValue').val(iva.toFixed(2).toString());

            newLineValueIVA = '';
            newLineDescription = '';
            newLineValue = '';

            openNewLineDialog(-1);
        }

        function getEditLineValues(line) {
            $('#div' + line + 'Description').html(newLineDescription);
            $('#div' + line + 'Value').html(parseFloat(newLineValue).toFixed(2).toString() + '€');
            $('#div' + line + 'IVA').html(parseFloat(newLineValueIVA).toFixed(2).toString() + '%');

            newLineValueIVA = '';
            newLineDescription = '';
            newLineValue = '';

            updateTotalValue();
            updateTotalIvaValue();
        }

        function getData() {
            loadingOn('A carregar dados!<br />Por favor aguarde...');
            var id = $('#txtAux').val();

            if (id != null && id != 'null' && id != '') {
                $.ajax({
                    type: "POST",
                    url: "config_ficha_venda.aspx/getData",
                    data: '{"id":"' + id + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var dados = res.d.split('<#SEP#>');

                        // Prepara o retorno dos dados
                        var cliente = dados[0];
                        var morada_cliente = dados[1];
                        var localidade_cliente = dados[2];
                        var codpostal_cliente = dados[3];
                        var nif_cliente = dados[4];
                        var data_venda = dados[5];
                        var descricao = dados[6];
                        var valortotal = dados[7];
                        var valoriva = dados[8];
                        linesInserted = parseInt(dados[9]);
                        var paga = dados[10]
                        var numero = dados[11];
                        var data_vencimento = dados[12];
                        var metodo_pagamento = dados[13];

                        $('#txtCustomerName').val(cliente);
                        $('#txtCustomerAddress').val(morada_cliente);
                        $('#txtCustomerZipCode').val(codpostal_cliente);
                        $('#txtCustomerCity').val(localidade_cliente);
                        $('#txtCustomerNIF').val(nif_cliente);
                        $('#txtDescription').val(descricao);
                        $('#txtTotalValue').val(valortotal);
                        $('#txtIvaValue').val(valoriva);
                        $('#txtNumber').val(numero);
                        $('#txtPaymentMethod').val(metodo_pagamento);

                        if (paga == "false")
                            $('#chkPayed').attr('checked', false);
                        else
                            $('#chkPayed').attr('checked', true);

                        onChangeCheckboxPayed();
                        setDatePicker(data_venda, data_vencimento);
                        reportLines();
                    }
                });
            }
            else {
                $('#txtCustomerName').val('');
                $('#txtCustomerAddress').val('');
                $('#txtCustomerZipCode').val('');
                $('#txtCustomerCity').val('');
                $('#txtCustomerNIF').val('');
                setDatePicker('', '');
                $('#txtDescription').val('');
                $('#txtTotalValue').val('0.00');
                $('#txtIvaValue').val('0.00');
                $('#txtNumber').val('');
                $('#txtMethod').val('');
                $('#chkPayed').attr('checked', false);
                onChangeCheckboxPayed();
                linesInserted = 0;
                reportLines();
            }
        }

        function reportLines() {
            var id = $('#txtAux').val();

            if (id != null && id != 'null' && id != '') {
                $.ajax({
                    type: "POST",
                    url: "config_ficha_venda.aspx/getLinesData",
                    data: '{"id":"' + id + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        $('#divLines').html(res.d);
                        defineValues();
                        loadingOff();
                    }
                });
            }
            else {
                $('#divLines').html('');
                defineValues();
                loadingOff();
            }
        }

        function saveData() {
            var id = $('#txtAux').val();
            var xml = '';
            var customerName = $('#txtCustomerName').val();
            var customerAddress = $('#txtCustomerAddress').val();
            var customerZipCode = $('#txtCustomerZipCode').val();
            var customerCity = $('#txtCustomerCity').val();
            var customerNIF = $('#txtCustomerNIF').val();
            var date = $('#txtDate').val();
            var description = $('#txtDescription').val();
            var totalValue = $('#txtTotalValue').val();
            var ivaValue = $('#txtvaValue').val();
            var number = $('#txtNumber').val();
            var dueDate = $('#txtDueDate').val();
            var paymentMethod = $('#txtPaymentMethod').val();
            var payed = $("#chkPayed").is(":checked") ? '1' : '0';

            if (id == null || id == 'null' || id == '') {
                id = '0';
            }

            if (customerName == '' || customerName == null || customerName == undefined) {
                sweetAlertWarning('Nome do Cliente', 'Por favor indique o nome do cliente');
                return;
            }
            else if (customerAddress == '' || customerAddress == null || customerAddress == undefined) {
                sweetAlertWarning('Morada do Cliente', 'Por favor indique a morada do cliente');
                return;
            }
            else if (customerZipCode == '' || customerZipCode == null || customerZipCode == undefined) {
                sweetAlertWarning('Código Postal do Cliente', 'Por favor indique o código postal do cliente');
                return;
            }
            else if (customerCity == '' || customerCity == null || customerCity == undefined) {
                sweetAlertWarning('Localidade do Cliente', 'Por favor indique a localidade do cliente');
                return;
            }
            else if (customerNIF == '' || customerNIF == null || customerNIF == undefined) {
                sweetAlertWarning('NIF do Cliente', 'Por favor indique o NIF do cliente');
                return;
            }
            else if (date == '' || date == null || date == undefined) {
                sweetAlertWarning('Data', 'Por favor indique a data');
                return;
            }
            else if (description == '' || description == null || description == undefined) {
                description = '';
            }
            else if (totalValue == '' || totalValue == null || totalValue == undefined) {
                totalValue = '0';
            }
            else if (ivaValue == '' || ivaValue == null || ivaValue == undefined) {
                ivaValue = '0';
            }
            else if (dueDate == '' || dueDate == null || dueDate == undefined) {
                sweetAlertWarning('Data de Vencimento', 'Por favor indique a data de vencimento');
                return;
            }
            else if (number == '' || number == null || number == undefined) {
                sweetAlertWarning('Nº da Fatura', 'Por favor indique o nº da fatura');
                return;
            }

            xml += '<DOC>';
            xml += '<ID>' + id + '</ID>';
            xml += '<DATA>' + date + '</DATA>';
            xml += '<DESCRICAO>' + description + '</DESCRICAO>';
            xml += '<VALORTOTAL>' + totalValue + '</VALORTOTAL>';
            xml += '<VALORIVA>' + ivaValue + '</VALORIVA>';
            xml += '<PAGA>' + payed + '</PAGA>';
            xml += '<METODO_PAGAMENTO>' + paymentMethod + '</METODO_PAGAMENTO>';
            xml += '<NUMERO>' + number + '</NUMERO>';
            xml += '<DATA_VENCIMENTO>' + dueDate + '</DATA_VENCIMENTO>';
            xml += '<CLIENTE>';
            xml += '<NOME>' + customerName + '</NOME>';
            xml += '<MORADA>' + customerAddress + '</MORADA>';
            xml += '<CODPOSTAL>' + customerZipCode + '</CODPOSTAL>';
            xml += '<LOCALIDADE>' + customerCity + '</LOCALIDADE>';
            xml += '<NIF>' + customerNIF + '</NIF>';
            xml += '</CLIENTE>';
            xml += '<LINHAS>' + getXmlLines() + '</LINHAS>';
            xml += '</DOC>';

            $.ajax({
                type: "POST",
                url: "config_ficha_venda.aspx/saveData",
                data: '{"idUser":"' + localStorage.loga + '","xml":"' + xml + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');

                    if (parseInt(dados[0]) < 0) {
                        sweetAlertError(title, dados[1]);
                    }
                    else {
                        loadUrl("lista_vendas.aspx");
                    }
                }
            });
        }

        function getXmlLines() {
            var xml = '';

            for (let i = 0; i < linesInserted; i++) {
                var id = $('#div' + i + 'Id').html();
                var desc = $('#div' + i + 'Description').html();
                var tot = $('#div' + i + 'Value').html();
                var ivaVal = $('#div' + i + 'IVA').html();

                xml += '<LINHA>';
                xml += '<ID>' + id + '</ID>';
                xml += '<DESCRICAO>' + desc + '</DESCRICAO>';
                xml += '<VALORSEMIVA>' + tot.replace('€', '') + '</VALORSEMIVA>';
                xml += '<IVA>' + ivaVal.replace('%', '') + '</IVA>';
                xml += '</LINHA>';
            }

            return xml;
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
                    loadUrl('lista_vendas.aspx');
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

        function defineValues() {
            newLine = "<div class='row'><div class='col-md-12'><div class='form-group'>"
                + "<label class='form-control-label' for='txtNewLineDescription'>Descrição</label>"
                + "<textarea type='text' id='txtNewLineDescription' class='form-control form-control-alternative auto_height' oninput='auto_height(this)' placeholder='Descrição'>[txtNewLineDescription_value]</textarea>"
                + "</div></div>"
                + "<div class='col-md-12'><div class='form-group'>"
                + "<label class='form-control-label' for='txtNewLineValue'>Valor Sem IVA</label>"
                + "<input type='number' id='txtNewLineValue' class='form-control form-control-alternative' placeholder='Valor sem IVA' value='[txtNewLineValue_value]'>"
                + "</div></div>"
                + "<div class='col-md-12'><div class='form-group'>"
                + "<label class='form-control-label' for='valueIVA'>IVA</label>"
                + "<select name='valueIVA' id='valueIVA' class='form-control form-control-alternative'>"
                + "<option value='23'>23%</option>"
                + "<option value='0'>0%</option>"
                + "</select>"
                + "</div></div>"
                + "</div>";

            newLineTemplate = "<div class='row pointer margin_lines_row" + (linesInserted % 2 != 0 ? " background_white " : "") + "' id='line" + linesInserted + "' ondblclick='openNewLineDialog(" + linesInserted + ");'>"
                + "<div class='variaveis' id='div" + linesInserted + "Id'>0</div>"
                + "<div class='col-md-6' id='div" + linesInserted + "Description'>[NEWLINE_DESCRIPTION]</div>"
                + "<div class='col-md-3' id='div" + linesInserted + "Value'>[NEWLINE_VALUE]</div>"
                + "<div class='col-md-3' id='div" + linesInserted + "IVA'>[NEWLINE_IVA]</div>"
                + "</div>";
        }

        function checkCustomer() {
            var text = $('#txtCustomerNIF').val();

            if (text != '' && text != null && text != undefined) {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/checkExistentCarOrCustomer",
                    data: '{"text":"' + text + '","customer":"' + '1' + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        if (parseInt(res.d) > 0) {
                            var title = "CLIENTE";
                            var msg = 'O cliente com o NIF inserido já existe no sistema!';
                            getCustomerData(text);
                        }
                        else {
                            validarnif();
                        }
                    }
                });
            }
        }

        function checkDueDate() {
            var date = $('#txtDate').val();
            var numDias = $('#txtAuxNumeroDiasPagamento').val();

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

        function showHideCustomer() {
            if ($('#customerNameRow').is(":visible")) {
                $('#customerNameRow').fadeOut();
                $('#customerAddressRow').fadeOut();
                $('#customerZipCodeCityRow').fadeOut();
                $('#customerNIFRow').fadeOut();
            }
            else {
                $('#customerNameRow').fadeIn();
                $('#customerAddressRow').fadeIn();
                $('#customerZipCodeCityRow').fadeIn();
                $('#customerNIFRow').fadeIn();
            }
        }

        function showHideData() {
            if ($('#numberDatesRow').is(":visible")) {
                $('#numberDatesRow').fadeOut();
                $('#payDataRow').fadeOut();
                $('#descriptionRow').fadeOut();
                $('#valuesRow').fadeOut();
            }
            else {
                $('#numberDatesRow').fadeIn();
                $('#payDataRow').fadeIn();
                $('#descriptionRow').fadeIn();
                $('#valuesRow').fadeIn();
            }
        }

        function showHideLinesData() {
            if ($('#linesHeader').is(":visible")) {
                $('#linesHeader').fadeOut();
                $('#divLines').fadeOut();
            }
            else {
                $('#linesHeader').fadeIn();
                $('#divLines').fadeIn();
            }
        }

        function auto_height(elem) {  /* javascript */
            elem.style.height = "1px";
            elem.style.height = (elem.scrollHeight) + "px";
        }

        function updateTotalValue() {
            var total = 0.0;

            for (let i = 0; i < linesInserted; i++) {
                var value = parseFloat($('#div' + i + 'Value').html().replace('€', ''));
                var iva = 0.01 * parseFloat($('#div' + i + 'IVA').html().replace('%', ''));
                total += (value * (1 + iva));
            }

            $('#txtTotalValue').val(total.toFixed(2).toString());
        }

        function updateTotalIvaValue() {
            var total = 0.0;

            for (let i = 0; i < linesInserted; i++) {
                var value = parseFloat($('#div' + i + 'Value').html().replace('€', ''));
                var iva = 0.01 * parseFloat($('#div' + i + 'IVA').html().replace('%', ''));
                total += (value * iva);
            }

            $('#txtIvaValue').val(total.toFixed(2).toString());
        }


        function validarnif() {
            var nif = $("#txtCustomerNIF").val();

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
                        sweetAlertError("CLIENTE", msg);
                    }
                    else {
                        sweetAlertInfo("CLIENTE", msg);

                        if (dados.length > 2) {
                            var nome = dados[2];
                            var morada = dados[3];
                            var codpostal = dados[4];
                            var localidade = dados[5];
                            var email = dados[6];
                            var notas = dados[7];

                            $('#txtCustomerName').val(nome);
                            $('#txtCustomerAddress').val(morada);
                            $('#txtCustomerZipCode').val(codpostal);
                            $('#txtCustomerCity').val(localidade);
                        }
                    }
                }
            });
        }

        function checkFocus() {
            if ($("#carSearchBar").is(":focus")) {
                getCarsList();
                return;
            }

            if ($("#txtCustomerName").is(":focus")) {
                $('#txtCustomerAddress').focus();
                return;
            }

            if ($("#txtCustomerAddress").is(":focus")) {
                $('#txtCustomerZipCode').focus();
                return;
            }

            if ($("#txtCustomerZipCode").is(":focus")) {
                $('#txtCustomerCity').focus();
                return;
            }

            if ($("#txtCustomerCity").is(":focus")) {
                $('#txtCustomerNIF').focus();
                return;
            }

            if ($("#txtCustomerNIF").is(":focus")) {
                $('#txtNumber').focus();
                return;
            }

            if ($("#txtNumber").is(":focus")) {
                $('#txtDate').focus();
                return;
            }

            if ($("#txtDate").is(":focus")) {
                $('#txtDueDate').focus();
                return;
            }

            if ($("#txtDueDate").is(":focus")) {
                $('#txtPaymentMethod').focus();
                return;
            }

            if ($("#txtPaymentMethod").is(":focus")) {
                $('#txtDescription').focus();
                return;
            }

            if ($("#txtDescription").is(":focus")) {
                $('#txtDescription').blur();
                return;
            }
        }
    </script>
</body>

</html>
