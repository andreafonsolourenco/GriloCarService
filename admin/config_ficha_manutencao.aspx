<%@ Page Language="C#" AutoEventWireup="true" CodeFile="config_ficha_manutencao.aspx.cs" Inherits="config_ficha_manutencao" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Grilo Car Service Software - Ficha de Manutenção / Orçamento">
    <meta name="author" content="André Lourenço">
    <title>Grilo Car Service Software - Ficha de Manutenção / Orçamento</title>
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
                        <h1 class="display-2 text-white" id="divInfoTitle"></h1>
                        <p class="text-white mt-0 mb-5" id="divInfoSubTitle"></p>
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
                                            <h3 class="mb-0" id="sectionTitle"></h3>
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
                                        <input type="text" id="txtCustomerNIF" class="form-control form-control-alternative" placeholder="NIF do Cliente" onfocusout="checkCustomerOrCar(true);">
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <table style="width: 100%; margin-left: 15px;">
                                    <tr>
                                        <td style="width: 90%">
                                            <h6 class="heading-small text-muted mb-4 pointer" onclick="showHideCar();">VIATURA</h6>
                                        </td>
                                        <td style="width: 10%; text-align: right">
                                            <img src='../Img/search_icon.png' style='width: 30px; height: 30px; cursor: pointer; margin-left: 10px;' alt='Pesquisar Viatura' title='Pesquisar Viatura' onclick='searchCar();'/>
                                        </td>
                                    </tr>
                                </table>
                            </div>

                            <div class="row" id="carBrandModelRow">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCarBrand">Marca</label>
                                        <input type="text" id="txtCarBrand" class="form-control form-control-alternative" placeholder="Marca da Viatura">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCarModel">Modelo</label>
                                        <input type="text" id="txtCarModel" class="form-control form-control-alternative" placeholder="Modelo da Viatura">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="carYearRegistrationKmsRow">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCarRegistration">Matrícula</label>
                                        <input type="text" id="txtCarRegistration" class="form-control form-control-alternative" placeholder="Matrícula da Viatura" onfocusout="checkCustomerOrCar(false);">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCarYear">Ano</label>
                                        <input type="number" id="txtCarYear" class="form-control form-control-alternative" placeholder="Ano da Viatura">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCarKms">Kms</label>
                                        <input type="number" id="txtCarKms" class="form-control form-control-alternative" placeholder="Kms da Viatura">
                                    </div>
                                </div>
                            </div>

                            <h6 class="heading-small text-muted mb-4 pointer" onclick="showHideEstimateMaintenanceData();" id="estimate_maintenance_title"></h6>

                            <div class="row" id="estimateMaintenanceTypeRow" style="margin-bottom:25px;">
                                <div class="col-md-4">
                                    <div class="custom-control custom-control-alternative custom-checkbox">
                                        <input class="custom-control-input" id="chkMechanics" type="checkbox" onclick="onChangeCheckboxMechanics();" checked>
                                        <label class="custom-control-label" for="chkMechanics">
                                            <span class="text-muted">Mecânica</span>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="custom-control custom-control-alternative custom-checkbox">
                                        <input class="custom-control-input" id="chkBodyWork" type="checkbox" onclick="onChangeCheckboxBodyWork();" >
                                        <label class="custom-control-label" for="chkBodyWork">
                                            <span class="text-muted">Bate-Chapas</span>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="custom-control custom-control-alternative custom-checkbox">
                                        <input class="custom-control-input" id="chkReview" type="checkbox" checked>
                                        <label class="custom-control-label" for="chkReview">
                                            <span class="text-muted">Revisão</span>
                                        </label>
                                    </div>
                                </div>
                             </div>

                            <div class="row" id="estimateMaintenanceRevisionDateRow">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtInvoiceNumber">Nº Fatura</label>
                                        <input type="text" id="txtInvoiceNumber" class="form-control form-control-alternative" placeholder="Nº da Fatura">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group" id="datepicker">
                                        <label class="form-control-label" for="txtMaintenanceDate">Data</label>
                                        <input type="text" id="txtMaintenanceDate" class="form-control form-control-alternative" placeholder="Data">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group" id="duedatepicker">
                                        <label class="form-control-label" for="txtInvoiceDueDate">Data de Vencimento</label>
                                        <input type="text" id="txtInvoiceDueDate" class="form-control form-control-alternative" placeholder="Data de Vencimento">
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="estimateMaintenancePayDataRow">
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
                                        <label class="form-control-label" for="txtInvoicePaymentMethod">Método de Pagamento</label>
                                        <textarea type="text" id="txtInvoicePaymentMethod" class="form-control form-control-alternative auto_height" oninput="auto_height(this)" placeholder="Método de Pagamento da Fatura"></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="estimateMaintenanceDescriptionRow">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtEstimateMaintenanceDescription">Descrição</label>
                                        <textarea type="text" id="txtEstimateMaintenanceDescription" class="form-control form-control-alternative auto_height" oninput="auto_height(this)" placeholder="Descrição"></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="row" id="estimateMaintenanceValuesRow">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtEstimateMaintenanceTotalValue">Valor Total</label>
                                        <input type="number" id="txtEstimateMaintenanceTotalValue" class="form-control form-control-alternative" placeholder="Valor Total" disabled>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtEstimateMaintenanceIvaValue">Valor IVA</label>
                                        <input type="number" id="txtEstimateMaintenanceIvaValue" class="form-control form-control-alternative" placeholder="Valor IVA" disabled>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <table style="width: 100%;">
                                        <tr>
                                            <td style="width: 90%">
                                                <h6 class="heading-small text-muted mb-4 pointer" onclick="showHideEstimateMaintenanceLinesData();">LINHAS</h6>
                                            </td>
                                            <td style="width: 10%; text-align: right">
                                                <img src='../Img/plus_icon.png' style='width: 30px; height: 30px; cursor: pointer; margin-left: 10px;' alt='Adicionar Linha' title='Adicionar Linha' onclick='openNewLineDialog(-1);'/>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>

                            <div class="row" id="linesHeader" style="margin-bottom: 20px;">
                                <div class="col-md-6" style="font-weight: bold">
                                    DESCRIÇÃO
                                </div>
                                <div class="col-md-2" style="font-weight: bold">
                                    VALOR SEM IVA
                                </div>
                                <div class="col-md-2" style="font-weight: bold">
                                    IVA
                                </div>
                                <div class="col-md-2" style="font-weight: bold">
                                    
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
                <input id="txtAuxOrcamento" runat="server" type="text" class="variaveis" />
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
        var title = "";
        var backPage = "";
        var subTitle = "";
        var idCustomerSelected = "";
        var idCarSelected = "";
        var tableCustomers = "";
        var tableCars = "";
        var customerIDSelected = "";
        var carIDSelected = "";
        var customerDialogOpen = false;
        var carDialogOpen = false;
        var newLine = "";
        var newLineDescription = "";
        var newLineValue = "";
        var newLineValueIVA = "";
        var newLineTemplate = "";
        var linesInserted = 0;
        var administrador;
        var tempLine = -1;

        $(document).ready(function () {
            loga();
            setAltura();
            getCustomersList();
            getCarsList();
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

            $('#txtMaintenanceDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtMaintenanceDate').datepicker('setDate', invoiceDate).on('changeDate', function (e) {
                checkDueDate();
            });
            $('#txtMaintenanceDate').val(dateToBeUsed);

            $('#txtInvoiceDueDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtInvoiceDueDate').datepicker('setDate', dueDate);
            $('#txtInvoiceDueDate').val(dueDateToBeUsed);
        }

        function onChangeCheckboxMechanics() {
            var checkbox = document.getElementById('chkMechanics');
            $('#chkBodyWork').prop('checked', !checkbox.checked);
            $('#chkReview').prop('disabled', !checkbox.checked);
        }

        function onChangeCheckboxBodyWork() {
            var checkbox = document.getElementById('chkBodyWork');
            $('#chkMechanics').prop('checked', !checkbox.checked);
            $('#chkReview').prop('disabled', checkbox.checked);
        }

        function onChangeCheckboxPayed() {
            var checkbox = document.getElementById('chkPayed');
            $('#txtInvoicePaymentMethod').prop('disabled', !checkbox.checked);
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
                url: "config_ficha_manutencao.aspx/getCustomersList",
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

        function getCarsList() {
            var search = "";
            var open = "0";

            if (carDialogOpen) {
                search = $('#carSearchBar').val().trim();
                open = "1";
            }

            $.ajax({
                type: "POST",
                url: "config_ficha_manutencao.aspx/getCarsList",
                data: '{"search":"' + search + '","dialogOpen":"' + open + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    if (carDialogOpen) {
                        $('#divTableCars').html(res.d);
                    }
                    else {
                        tableCars = res.d;
                    }
                }
            });
        }

        function getCustomerData(nif) {
            $.ajax({
                type: "POST",
                url: "config_ficha_manutencao.aspx/getCustomerData",
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

        function getCarData(brand) {
            $.ajax({
                type: "POST",
                url: "config_ficha_manutencao.aspx/getCarData",
                data: '{"id":"' + carIDSelected + '","matricula":"' + brand + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');

                    var marca = dados[0];
                    var modelo = dados[1]
                    var matricula = dados[2];
                    var ano = dados[3];

                    $('#txtCarBrand').val(marca);
                    $('#txtCarModel').val(modelo);
                    $('#txtCarYear').val(ano);
                    $('#txtCarRegistration').val(matricula);

                    carIDSelected = "";
                    $('#txtInvoiceNumber').focus();
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

        function searchCar() {
            carDialogOpen = true;

            swal({
                title: "<strong>VIATURAS</strong>",
                html: tableCars,
                customClass: 'dialogWidth',
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (isConfirm) {
                carDialogOpen = false;

                if (isConfirm) {
                    getCarData('');
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

        function selectCarRow(id, i) {
            if (id == carIDSelected) {
                carIDSelected = "0";
                $('#carLine' + i).removeClass('highlight_line');
                return;
            }

            var total = parseInt($('#countCars').html());

            for (let x = 0; x < total; x++) {
                $('#carLine' + x).removeClass('highlight_line');
            }

            carIDSelected = id;
            $('#carLine' + i).addClass('highlight_line');
        }

        function openNewLineDialog(line) {
            var template = newLine;
            tempLine = line;

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

            $("#txtNewLineDescription").focus();
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
                + "<div class='variaveis' id='div" + linesInserted + "Removed'>0</div>"
                + "<div class='col-md-6' id='div" + linesInserted + "Description'>[NEWLINE_DESCRIPTION]</div>"
                + "<div class='col-md-2' id='div" + linesInserted + "Value'>[NEWLINE_VALUE]</div>"
                + "<div class='col-md-2' id='div" + linesInserted + "IVA'>[NEWLINE_IVA]</div>"
                + "<div class='col-md-2' id='div" + linesInserted + "RemoveIcon'>"
                + "<img src='../Img/remove_icon.png' style='width: 10%; height: auto; cursor: pointer;' alt='Remover Linha' title='Remover Linha' onclick='removeLine(" + linesInserted + ");' />"
                + "</div>"
                + "</div>";

            var tot = parseFloat(newLineValue) * (1 + (0.01 * parseFloat(newLineValueIVA)));
            var iva = parseFloat(newLineValue) * (0.01 * parseFloat(newLineValueIVA));

            tot += parseFloat($('#txtEstimateMaintenanceTotalValue').val());
            iva += parseFloat($('#txtEstimateMaintenanceIvaValue').val());

            $('#txtEstimateMaintenanceTotalValue').val(tot.toFixed(2).toString());
            $('#txtEstimateMaintenanceIvaValue').val(iva.toFixed(2).toString());

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
            var orcamento = $('#txtAuxOrcamento').val();
            if (id != null && id != 'null' && id != '') {
                $.ajax({
                    type: "POST",
                    url: "config_ficha_manutencao.aspx/getData",
                    data: '{"id":"' + id + '","orcamento":"' + orcamento + '"}',
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
                        var marca = dados[5];
                        var modelo = dados[6];
                        var ano = dados[7];
                        var matricula = dados[8];
                        var data_manutencao = dados[9];
                        var descricao = dados[10];
                        var valortotal = dados[11];
                        var valoriva = dados[12];
                        var kms_viatura = dados[13];
                        var mecanica = dados[14];
                        var batechapas = dados[15];
                        var revisao = dados[16];
                        linesInserted = parseInt(dados[17]);
                        var paga = dados[18]
                        var numero = dados[19];
                        var data_vencimento = dados[20];
                        var metodo_pagamento = dados[21];

                        $('#txtCustomerName').val(cliente);
                        $('#txtCustomerAddress').val(morada_cliente);
                        $('#txtCustomerZipCode').val(codpostal_cliente);
                        $('#txtCustomerCity').val(localidade_cliente);
                        $('#txtCustomerNIF').val(nif_cliente);
                        $('#txtCarBrand').val(marca);
                        $('#txtCarModel').val(modelo);
                        $('#txtCarRegistration').val(matricula);
                        $('#txtCarYear').val(ano);
                        $('#txtCarKms').val(kms_viatura);
                        $('#txtEstimateMaintenanceDescription').val(descricao);
                        $('#txtEstimateMaintenanceTotalValue').val(valortotal);
                        $('#txtEstimateMaintenanceIvaValue').val(valoriva);
                        $('#txtInvoiceNumber').val(numero);
                        $('#txtInvoicePaymentMethod').val(metodo_pagamento);

                        if (mecanica == "false")
                            $('#chkMechanics').attr('checked', false);
                        else
                            $('#chkMechanics').attr('checked', true);

                        if (batechapas == "false")
                            $('#chkBodyWork').attr('checked', false);
                        else
                            $('#chkBodyWork').attr('checked', true);

                        if (revisao == "false")
                            $('#chkReview').attr('checked', false);
                        else
                            $('#chkReview').attr('checked', true);

                        if (paga == "false")
                            $('#chkPayed').attr('checked', false);
                        else
                            $('#chkPayed').attr('checked', true);

                        onChangeCheckboxPayed();
                        setDatePicker(data_manutencao, data_vencimento);
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
                $('#txtCarBrand').val('');
                $('#txtCarModel').val('');
                $('#txtCarRegistration').val('');
                $('#txtCarYear').val('');
                $('#txtCarKms').val('');
                setDatePicker('', '');
                $('#txtEstimateMaintenanceDescription').val('');
                $('#txtEstimateMaintenanceTotalValue').val('0.00');
                $('#txtEstimateMaintenanceIvaValue').val('0.00');
                $('#txtInvoiceNumber').val('');
                $('#txtInvoicePaymentMethod').val('');

                $('#chkMechanics').attr('checked', true);
                $('#chkBodyWork').attr('checked', false);
                $('#chkReview').attr('checked', true);
                $('#chkPayed').attr('checked', false);
                onChangeCheckboxPayed();
                linesInserted = 0;
                reportLines();
            }
        }

        function reportLines() {
            var id = $('#txtAux').val();
            var orcamento = $('#txtAuxOrcamento').val();
            if (id != null && id != 'null' && id != '') {
                $.ajax({
                    type: "POST",
                    url: "config_ficha_manutencao.aspx/getLinesData",
                    data: '{"id":"' + id + '","orcamento":"' + orcamento + '"}',
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
            loadingOn('A guardar os dados!<br />Por favor aguarde...');
            var id = $('#txtAux').val();
            var orcamento = $('#txtAuxOrcamento').val();
            var xml = '';
            var customerName = $('#txtCustomerName').val();
            var customerAddress = $('#txtCustomerAddress').val();
            var customerZipCode = $('#txtCustomerZipCode').val();
            var customerCity = $('#txtCustomerCity').val();
            var customerNIF = $('#txtCustomerNIF').val();
            var carBrand = $('#txtCarBrand').val();
            var carModel = $('#txtCarModel').val();
            var carRegistration = $('#txtCarRegistration').val();
            var carYear = $('#txtCarYear').val();
            var kms = $('#txtCarKms').val();
            var mechanics = $("#chkMechanics").is(":checked") ? '1' : '0';
            var bodyWork = $("#chkBodyWork").is(":checked") ? '1' : '0';
            var review = $("#chkReview").is(":checked") ? '1' : '0';
            var date = $('#txtMaintenanceDate').val();
            var description = $('#txtEstimateMaintenanceDescription').val();
            var totalValue = $('#txtEstimateMaintenanceTotalValue').val();
            var ivaValue = $('#txtEstimateMaintenanceIvaValue').val();
            var number = $('#txtInvoiceNumber').val();
            var dueDate = $('#txtInvoiceDueDate').val();
            var paymentMethod = $('#txtInvoicePaymentMethod').val();
            var checkbox = document.getElementById('chkPayed');
            var paga = checkbox.checked ? '1' : '0';

            if (id == null || id == 'null' || id == '') {
                id = '0';
            }

            if (bodyWork == '1') {
                review = '0';
            }

            if (carYear == '' || carYear == null || carYear == undefined || carYear.length === 0) {
                carYear = '0';
            }

            if (kms == '' || kms == null || kms == undefined || kms.length === 0) {
                kms = '0';
            }

            if (description == '' || description == null || description == undefined) {
                description = '';
            }

            if (totalValue == '' || totalValue == null || totalValue == undefined) {
                totalValue = '0';
            }

            if (ivaValue == '' || ivaValue == null || ivaValue == undefined) {
                ivaValue = '0';
            }

            if (customerName == '' || customerName == null || customerName == undefined) {
                loadingOff();
                sweetAlertWarning('Nome do Cliente', 'Por favor indique o nome do cliente');
                return;
            }
            else if (customerAddress == '' || customerAddress == null || customerAddress == undefined) {
                loadingOff();
                sweetAlertWarning('Morada do Cliente', 'Por favor indique a morada do cliente');
                return;
            }
            else if (customerZipCode == '' || customerZipCode == null || customerZipCode == undefined) {
                loadingOff();
                sweetAlertWarning('Código Postal do Cliente', 'Por favor indique o código postal do cliente');
                return;
            }
            else if (customerCity == '' || customerCity == null || customerCity == undefined) {
                loadingOff();
                sweetAlertWarning('Localidade do Cliente', 'Por favor indique a localidade do cliente');
                return;
            }
            else if (customerNIF == '' || customerNIF == null || customerNIF == undefined) {
                loadingOff();
                sweetAlertWarning('NIF do Cliente', 'Por favor indique o NIF do cliente');
                return;
            }
            else if (carBrand == '' || carBrand == null || carBrand == undefined) {
                loadingOff();
                sweetAlertWarning('Marca da Viatura', 'Por favor indique a marca da viatura');
                return;
            }
            else if (carModel == '' || carModel == null || carModel == undefined) {
                loadingOff();
                sweetAlertWarning('Modelo da Viatura', 'Por favor indique o modelo da viatura');
                return;
            }
            else if (carRegistration == '' || carRegistration == null || carRegistration == undefined) {
                loadingOff();
                sweetAlertWarning('Matrícula da Viatura', 'Por favor indique a matrícula da viatura');
                return;
            }
            else if (date == '' || date == null || date == undefined) {
                loadingOff();
                sweetAlertWarning('Data', 'Por favor indique a data');
                return;
            }

            if (orcamento == '0') {
                if (dueDate == '' || dueDate == null || dueDate == undefined) {
                    loadingOff();
                    sweetAlertWarning('Data de Vencimento', 'Por favor indique a data de vencimento');
                    return;
                }

                if (number == '' || number == null || number == undefined) {
                    loadingOff();
                    sweetAlertWarning('Nº da Fatura', 'Por favor indique o nº da fatura');
                    return;
                }
            }

            xml += '<DOC>';
            xml += '<ID>' + id + '</ID>';

            if (kms == '' || kms == null || kms == undefined || kms.length === 0) {
                xml += '<KMS>0</KMS>';
            }
            else {
                xml += '<KMS>' + kms + '</KMS>';
            }

            if (description == '' || description == null || description == undefined || description.length === 0) {
                xml += '<DESCRICAO></DESCRICAO>';
            }
            else {
                xml += '<DESCRICAO>' + description + '</DESCRICAO>';
            }
            
            xml += '<MECANICA>' + mechanics + '</MECANICA>';
            xml += '<BATECHAPAS>' + bodyWork + '</BATECHAPAS>';
            xml += '<REVISAO>' + review + '</REVISAO>';
            xml += '<DATA>' + date + '</DATA>';
            
            if (totalValue == '' || totalValue == null || totalValue == undefined || totalValue.length === 0) {
                xml += '<VALORTOTAL>0.0</VALORTOTAL>';
            }
            else {
                xml += '<VALORTOTAL>' + totalValue + '</VALORTOTAL>';
            }

            if (ivaValue == '' || ivaValue == null || ivaValue == undefined || ivaValue.length === 0) {
                xml += '<VALORIVA>0.0</VALORIVA>';
            }
            else {
                xml += '<VALORIVA>' + ivaValue + '</VALORIVA>';
            }
            
            xml += '<ORCAMENTO>' + orcamento + '</ORCAMENTO>';
            xml += '<PAGA>' + paga + '</PAGA>';
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
            xml += '<VIATURA>';
            xml += '<MARCA>' + carBrand + '</MARCA>';
            xml += '<MODELO>' + carModel + '</MODELO>';
            xml += '<MATRICULA>' + carRegistration + '</MATRICULA>';

            if (carYear == '' || carYear == null || carYear == undefined || carYear.length === 0) {
                xml += '<ANO>0</ANO>';
            }
            else {
                xml += '<ANO>' + carYear + '</ANO>';
            }
            
            xml += '</VIATURA>';
            xml += '<LINHAS>' + getXmlLines() + '</LINHAS>';
            xml += '</DOC>';

            $.ajax({
                type: "POST",
                url: "config_ficha_manutencao.aspx/saveData",
                data: '{"idUser":"' + localStorage.loga + '","xml":"' + xml + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    loadingOff();

                    if (parseInt(dados[0]) < 0) {
                        sweetAlertError(title, dados[1]);
                    }
                    else {
                        loadUrl("lista_manutencoes.aspx?orcamento=" + orcamento);
                    }
                }
            });
        }

        function getXmlLines() {
            var xml = '';

            for (let i = 0; i < linesInserted; i++) {
                var removed = $('#div' + i + 'Removed').html();
                var id = $('#div' + i + 'Id').html();
                var desc = $('#div' + i + 'Description').html();
                var tot = $('#div' + i + 'Value').html();
                var ivaVal = $('#div' + i + 'IVA').html();

                if (removed == '0') {
                    xml += '<LINHA>';
                    xml += '<ID>' + id + '</ID>';
                    xml += '<DESCRICAO>' + desc + '</DESCRICAO>';
                    xml += '<VALORSEMIVA>' + tot.replace('€', '') + '</VALORSEMIVA>';
                    xml += '<IVA>' + ivaVal.replace('%', '') + '</IVA>';
                    xml += '</LINHA>';
                }
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
                    loadUrl(backPage);
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
            if ($('#txtAuxOrcamento').val() == '1') {
                title = "Orçamento";
                backPage = "lista_orcamentos.aspx";
                subTitle = "Crie/Edite os Orçamentos";
            }
            else {
                title = "Manutenção";
                backPage = "lista_manutencoes.aspx";
                subTitle = "Crie/Edite as Manutenções";
            }

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
                + "<div class='variaveis' id='div" + linesInserted + "Removed'>0</div>"
                + "<div class='col-md-6' id='div" + linesInserted + "Description'>[NEWLINE_DESCRIPTION]</div>"
                + "<div class='col-md-2' id='div" + linesInserted + "Value'>[NEWLINE_VALUE]</div>"
                + "<div class='col-md-2' id='div" + linesInserted + "IVA'>[NEWLINE_IVA]</div>"
                + "<div class='col-md-2' id='div" + linesInserted + "RemoveIcon'>"
                + "<img src='../Img/remove_icon.png' style='width: 10%; height: auto; cursor: pointer;' alt='Remover Linha' title='Remover Linha' onclick='removeLine(" + linesInserted + ");' />"
                + "</div>"
                + "</div>";

            $('#pageTitle').html(title);
            $('#divInfoTitle').html(title);
            $('#divInfoSubTitle').html(subTitle);
            $('#estimate_maintenance_title').html(title.toUpperCase());
            $('#sectionTitle').html(title);
        }

        function checkCustomerOrCar(customer) {
            var text = "";
            var cust = customer ? '1' : '0';

            if (customer) {
                text = $('#txtCustomerNIF').val();
            }
            else {
                text = $('#txtCarRegistration').val();
            }

            if (text != '' && text != null && text != undefined) {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/checkExistentCarOrCustomer",
                    data: '{"text":"' + text + '","customer":"' + cust + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        if (parseInt(res.d) > 0) {
                            var title = customer ? "CLIENTE" : "VIATURA";
                            var msg = customer ? 'O cliente com o NIF inserido já existe no sistema!' : 'A viatura com a matrícula inserida já existe no sistema!';
                            if (customer) {
                                getCustomerData(text);
                            }
                            else {
                                getCarData(text);
                            }
                        }
                        else {
                            if (customer) {
                                validarnif();
                            }
                        }
                    }
                });
            }
        }

        function checkDueDate() {
            var date = $('#txtMaintenanceDate').val();
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

        function showHideCar() {
            if ($('#carBrandModelRow').is(":visible")) {
                $('#carBrandModelRow').fadeOut();
                $('#carYearRegistrationKmsRow').fadeOut();
            }
            else {
                $('#carBrandModelRow').fadeIn();
                $('#carYearRegistrationKmsRow').fadeIn();
            }
        }

        function showHideEstimateMaintenanceData() {
            if ($('#estimateMaintenanceTypeRow').is(":visible")) {
                $('#estimateMaintenanceTypeRow').fadeOut();
                $('#estimateMaintenanceRevisionDateRow').fadeOut();
                $('#estimateMaintenanceDescriptionRow').fadeOut();
                $('#estimateMaintenanceValuesRow').fadeOut();
                $('#estimateMaintenancePayDataRow').fadeOut();
            }
            else {
                $('#estimateMaintenanceTypeRow').fadeIn();
                $('#estimateMaintenanceRevisionDateRow').fadeIn();
                $('#estimateMaintenanceDescriptionRow').fadeIn();
                $('#estimateMaintenanceValuesRow').fadeIn();
                $('#estimateMaintenancePayDataRow').fadeIn();
            }
        }

        function showHideEstimateMaintenanceLinesData() {
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
                var removed = $('#div' + i + 'Removed').html();
                var value = parseFloat($('#div' + i + 'Value').html().replace('€', ''));
                var iva = 0.01 * parseFloat($('#div' + i + 'IVA').html().replace('%', ''));
                if (removed == '0') {
                    total += (value * (1 + iva));
                }                
            }

            $('#txtEstimateMaintenanceTotalValue').val(total.toFixed(2).toString());
        }

        function updateTotalIvaValue() {
            var total = 0.0;

            for (let i = 0; i < linesInserted; i++) {
                var removed = $('#div' + i + 'Removed').html();
                var value = parseFloat($('#div' + i + 'Value').html().replace('€', ''));
                var iva = 0.01 * parseFloat($('#div' + i + 'IVA').html().replace('%', ''));
                if (removed == '0') {
                    total += (value * iva);
                }                
            }

            $('#txtEstimateMaintenanceIvaValue').val(total.toFixed(2).toString());
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

            if ($("#customerSearchBar").is(":focus")) {
                getCustomersList();
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
                $('#txtCarBrand').focus();
                return;
            }

            if ($("#txtCarBrand").is(":focus")) {
                $('#txtCarModel').focus();
                return;
            }

            if ($("#txtCarModel").is(":focus")) {
                $('#txtCarRegistration').focus();
                return;
            }

            if ($("#txtCarRegistration").is(":focus")) {
                $('#txtCarYear').focus();
                return;
            }

            if ($("#txtCarYear").is(":focus")) {
                $('#txtCarKms').focus();
                return;
            }

            if ($("#txtCarKms").is(":focus")) {
                $('#txtInvoiceNumber').focus();
                return;
            }

            if ($("#txtInvoiceNumber").is(":focus")) {
                $('#txtMaintenanceDate').focus();
                return;
            }

            if ($("#txtMaintenanceDate").is(":focus")) {
                $('#txtInvoiceDueDate').focus();
                return;
            }

            if ($("#txtInvoiceDueDate").is(":focus")) {
                $('#txtInvoicePaymentMethod').focus();
                return;
            }

            if ($("#txtInvoicePaymentMethod").is(":focus")) {
                $('#txtEstimateMaintenanceDescription').focus();
                return;
            }

            if ($("#txtEstimateMaintenanceDescription").is(":focus")) {
                $('#txtEstimateMaintenanceDescription').blur();
                return;
            }

            if ($("#txtNewLineDescription").is(":focus")) {
                $('#txtNewLineValue').focus();
                return;
            }

            if ($("#txtNewLineValue").is(":focus")) {
                getValues(tempLine);
                if (tempLine >= 0) {
                    tempLine = -1;
                    swal.close();
                }
                return;
            }
        }

        function removeLine(line) {
            swal({
                title: "REMOVER LINHA",
                text: "Tem a certeza que deseja remover a linha selecionada?",
                type: "question",
                showCancelButton: true,
                confirmButtonColor: '#007351',
                cancelButtonColor: '#d33',
                confirmButtonText: "Confirmar",
                cancelButtonText: "Cancelar"
            }).then(function (isConfirm) {
                if (isConfirm) {
                    $('#div' + line + 'Removed').html('1');
                    $('#line' + line).addClass('variaveis');
                    updateTotalValue();
                    updateTotalIvaValue();
                }
            });
        }
    </script>
</body>

</html>
