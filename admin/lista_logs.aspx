<%@ Page Language="C#" AutoEventWireup="true" CodeFile="lista_logs.aspx.cs" Inherits="lista_logs" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Grilo Car Service Software - Clientes">
    <meta name="author" content="André Lourenço">
    <title>Grilo Car Service Software - Clientes</title>
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




        <!-- Top navbar -->
        <nav class="navbar navbar-top navbar-expand-md navbar-dark" id="navbar-main">
            <div class="container-fluid">
                <!-- Brand -->
                <a class="h4 mb-0 text-white text-uppercase d-none d-lg-inline-block">Registo de Atividade</a>
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
                                    <td style="width: 65%; max-width: 65% !important;">
                                        <div style="float:left">
                                            <h3 class="mb-0">Registo de Atividade</h3>
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
                                </tr>
                            </table>
                            <br />
                            <table style="width: 100%">
                                <tr>
                                    <td style="width: 50%; max-width: 50% !important;">
                                        <div class="form-group" id="initialDatePicker">
                                            <label class="form-control-label" for="txtInitialDate">Data Inicial</label>
                                            <input type="text" id="txtInitialDate" class="form-control form-control-alternative" placeholder="Data Inicial">
                                        </div>
                                    </td>
                                    <td style="width: 50%; max-width: 50% !important;">
                                        <div class="form-group" id="finalDatePicker">
                                            <label class="form-control-label" for="txtFinalDate">Data Final</label>
                                            <input type="text" id="txtFinalDate" class="form-control form-control-alternative" placeholder="Data Final">
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <table style="width: 100%">
                                <tr>
                                    <td style="width: 15%; max-width: 15% !important;">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkLogin" type="checkbox">
                                            <label class="custom-control-label" for="chkLogin">
                                                <span class="text-muted">Login</span>
                                            </label>
                                        </div>
                                    </td>
                                    <td style="width: 15%; max-width: 15% !important;">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkSession" type="checkbox">
                                            <label class="custom-control-label" for="chkSession">
                                                <span class="text-muted">Sessão</span>
                                            </label>
                                        </div>
                                    </td>
                                    <td style="width: 10%; max-width: 10% !important;">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkLog" type="checkbox">
                                            <label class="custom-control-label" for="chkLog">
                                                <span class="text-muted">Log</span>
                                            </label>
                                        </div>
                                    </td>
                                    <td style="width: 15%; max-width: 15% !important;">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkCustomers" type="checkbox">
                                            <label class="custom-control-label" for="chkCustomers">
                                                <span class="text-muted">Clientes</span>
                                            </label>
                                        </div>
                                    </td>
                                    <td style="width: 15%; max-width: 15% !important;">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkCars" type="checkbox">
                                            <label class="custom-control-label" for="chkCars">
                                                <span class="text-muted">Viaturas</span>
                                            </label>
                                        </div>
                                    </td>
                                    <td style="width: 15%; max-width: 15% !important;">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkMaintenances" type="checkbox">
                                            <label class="custom-control-label" for="chkMaintenances">
                                                <span class="text-muted">Reparações</span>
                                            </label>
                                        </div>
                                    </td>
                                    <td style="width: 15%; max-width: 15% !important;">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkOrcamentos" type="checkbox">
                                            <label class="custom-control-label" for="chkOrcamentos">
                                                <span class="text-muted">Orçamentos</span>
                                            </label>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="table-responsive">
                            <div id="divGrelhaRegistos"></div>
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
        var ordData = 0;
        var ordUser = 0;
        var ordTipo = 0;
        var ordLog = 0;
        var administrador;
        var chkLogin = false;
        var chkSession = false;
        var chkLog = false;
        var chkCustomers = false;
        var chkCars = false;
        var chkMaintenances = false;
        var chkOrcamentos = false;

        $(document).ready(function () {
            setDatePicker();
            loga();
            setAltura();
            getTotals();
            setInterval(function () {
                getTotals();
            }, 5000);

            onChangeCheckboxs();
            onChangeDatePickers();

            $("#txtPesquisa").focus();
        });

        $(window).resize(function () {
            setAltura();
        });

        function finishSession() {
            window.top.location = "../general/login.aspx";
        }

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

        function setAltura() {
            $("#fraContent").height($(window).height());
        }

        function keyPesquisa(e) {
            if (e.keyCode == 13) {
                getData();
            }
        }

        function loadUrl(url) {
            window.location = url;
        }

        function onChangeCheckboxs() {
            $('#chkLogin').on('change', function () {
                chkLogin = this.checked;
                getData();
            });

            $('#chkSession').on('change', function () {
                chkSession = this.checked;
                getData();
            });

            $('#chkLog').on('change', function () {
                chkLog = this.checked;
                getData();
            });

            $('#chkCustomers').on('change', function () {
                chkCustomers = this.checked;
                getData();
            });

            $('#chkCars').on('change', function () {
                chkCars = this.checked;
                getData();
            });

            $('#chkMaintenances').on('change', function () {
                chkMaintenances = this.checked;
                getData();
            });

            $('#chkOrcamentos').on('change', function () {
                chkOrcamentos = this.checked;
                getData();
            });
        }

        function onChangeDatePickers() {
            $('#txtInitialDate').change(function () {
                getData();
            });

            $('#txtFinalDate').change(function () {
                getData();
            });
        }

        // Web services

        function getData() {
            loadingOn('A carregar o registo de atividade. Por favor aguarde...');
            var pesquisa = $('#txtPesquisa').val();
            var order = "";
            var typeQuery = "";
            var initialDate = $('#txtInitialDate').val();
            var finalDate = $('#txtFinalDate').val();
            var type = "";
            var countType = 0;
            var idUser = "";

            if (ordData == 0 && ordUser == 0 && ordTipo == 0 && ordLog == 0) {
                order = ' ORDER BY data_log desc, name_user asc, tipo asc';
            }
            else {
                order = ' ORDER BY ';

                if (ordData != 0) {
                    order += ordData == -1 ? ' data_log desc ' : ' data_log asc ';
                }
                else if (ordUser != 0) {
                    order += ordUser == -1 ? ' name_user desc ' : ' name_user asc ';
                }
                else if (ordTipo != 0) {
                    order += ordTipo == -1 ? ' tipo desc ' : ' tipo asc ';
                }
                else if (ordLog != 0) {
                    order += ordLog == -1 ? ' notas desc ' : ' notas asc ';
                }
            }

            if (!chkLogin && !chkSession && !chkLog && !chkCustomers && !chkCars && !chkMaintenances && !chkOrcamentos) {
                typeQuery = "";
            }
            else {
                typeQuery = " and (";

                if (chkLogin) {
                    typeQuery += " tipo = 'LOGIN' ";
                    countType++;
                }

                if (chkSession) {
                    if (typeQuery != " and (") {
                        typeQuery += " or tipo = 'SESSÃO' ";
                    }
                    else {
                        typeQuery += " tipo = 'SESSÃO' ";
                    }
                    countType++;
                }

                if (chkLog) {
                    if (typeQuery != " and (") {
                        typeQuery += " or tipo = 'LOG' ";
                    }
                    else {
                        typeQuery += " tipo = 'LOG' ";
                    }
                    countType++;
                }

                if (chkCustomers) {
                    if (typeQuery != " and (") {
                        typeQuery += " or tipo = 'CLIENTES' ";
                    }
                    else {
                        typeQuery += " tipo = 'CLIENTES' ";
                    }
                    countType++;
                }

                if (chkCars) {
                    if (typeQuery != " and (") {
                        typeQuery += " or tipo = 'VIATURAS' ";
                    }
                    else {
                        typeQuery += " tipo = 'VIATURAS' ";
                    }
                    countType++;
                }

                if (chkMaintenances) {
                    if (typeQuery != " and (") {
                        typeQuery += " or tipo = 'REPARAÇÕES' ";
                    }
                    else {
                        typeQuery += " tipo = 'REPARAÇÕES' ";
                    }
                    countType++;
                }

                if (chkOrcamentos) {
                    if (typeQuery != " and (") {
                        typeQuery += " or tipo = 'ORÇAMENTOS' ";
                    }
                    else {
                        typeQuery += " tipo = 'ORÇAMENTOS' ";
                    }
                    countType++;
                }

                typeQuery += ")";
            }

            if (countType == 1) {
                if (chkLogin) {
                    type = 'LOGIN';
                }
                else if (chkSession) {
                    type = 'SESSÃO';
                }
                else if (chkLog) {
                    type = 'LOG';
                }
                else if (chkCustomers) {
                    type = 'CLIENTES';
                }
                else if (chkCars) {
                    type = 'VIATURAS';
                }
                else if (chkMaintenances) {
                    type = 'REPARAÇÕES';
                }
                else if (chkOrcamentos) {
                    type = 'ORÇAMENTOS';
                }
            }

            $.ajax({
                type: "POST",
                url: "lista_logs.aspx/getGrelha",
                data: '{"pesquisa":"' + pesquisa + '","order":"' + order + '","typeQuery":"' + typeQuery + '","initialDate":"' + initialDate + '","finalDate":"' + finalDate + '","type":"' + type + '","idUser":"' + idUser + '"}',
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

        function visualizar(id) {
            $.ajax({
                type: "POST",
                url: "index.aspx/generateViewInfo",
                data: '{"idUser":"' + localStorage.loga + '","id":"' + id + '","tipo":"' + 'LOG' + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d;

                    swal({
                        title: "<strong>REGISTO DE ATIVIDADE</strong>",
                        html: dados,
                        showCancelButton: false,
                        confirmButtonColor: "#DD6B55",
                        confirmButtonText: "OK"
                    }).then(function () {
                        getData();
                    });
                }
            });
        }

        function ordenaData() {
            ordLog = 0;
            ordTipo = 0;
            ordUser = 0;

            if (ordData == 0) {
                ordData = 1;
            }
            else {
                ordData = ordData * (-1);
            }

            getData();
        }

        function ordenaUser() {
            ordLog = 0;
            ordTipo = 0;
            ordData = 0;

            if (ordUser == 0) {
                ordUser = 1;
            }
            else {
                ordUser = ordUser * (-1);
            }

            getData();
        }

        function ordenaTipo() {
            ordLog = 0;
            ordUser = 0;
            ordData = 0;

            if (ordTipo == 0) {
                ordTipo = 1;
            }
            else {
                ordTipo = ordTipo * (-1);
            }

            getData();
        }

        function ordenaLog() {
            ordTipo = 0;
            ordUser = 0;
            ordData = 0;

            if (ordLog == 0) {
                ordLog = 1;
            }
            else {
                ordLog = ordLog * (-1);
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
            overlayOff();
            document.getElementById("overlay").style.display = "block";
        }

        function overlayOff() {
            document.getElementById("overlay").style.display = "none";
        }

        function setDatePicker() {
            var todayStr = "";
            var today = new Date();
            var day = parseInt(today.getDate());
            var month = parseInt(today.getMonth()) + 1;
            var year = parseInt(today.getFullYear());

            if (day < 10) {
                todayStr += '0' + day;
            }
            else {
                todayStr += '' + day;
            }

            if (month < 10) {
                todayStr += '/0' + month;
            }
            else {
                todayStr += '/' + month;
            }

            todayStr += '/' + year;

            $('#txtInitialDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top' });
            $('#txtInitialDate').datepicker('setDate', todayStr);

            $('#txtFinalDate').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top' });
            $('#txtFinalDate').datepicker('setDate', todayStr);
        }
    </script>
</body>

</html>
