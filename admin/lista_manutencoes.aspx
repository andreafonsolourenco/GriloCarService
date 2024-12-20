<%@ Page Language="C#" AutoEventWireup="true" CodeFile="lista_manutencoes.aspx.cs" Inherits="lista_manutencoes" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Grilo Car Service Software - Reparações">
    <meta name="author" content="André Lourenço">
    <title>Grilo Car Service Software - Reparações</title>
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
                <a class="h4 mb-0 text-white text-uppercase d-none d-lg-inline-block" id="title"></a>
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
                                            <h3 class="mb-0" id="tableTitle">Reparações</h3>
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
                                        <div id="divBtnCreate">
                                            <a class="btn btn-sm btn-primary" onclick="novo();" style="color: #FFFFFF;" id="btnCreate"></a>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width: 50%; max-width: 50% !important;">
                                        <div style="float:left; margin-top: 10px !important;">
                                            <div class="form-group" id="datepickerDataInicial">
                                                <label class="form-control-label" for="txtDataInicial">De:</label>
                                                <input type="text" id="txtDataInicial" runat="server" class="form-control form-control-alternative" placeholder="Data Inicial">
                                            </div>
                                        </div>
                                    </td>
                                    <td style="width: 50%; max-width: 50% !important;" colspan="2">
                                        <div style="float:left; margin-top: 10px !important;">
                                            <div class="form-group" id="datepickerDataFinal">
                                                <label class="form-control-label" for="txtDataFinal">A:</label>
                                                <input type="text" id="txtDataFinal" runat="server" class="form-control form-control-alternative" placeholder="Data Final">
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="table-responsive">
                            <div id="divGrelhaRegistos" style="margin-bottom:75px;"></div>
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

            <div id="hiddenVals" class="variaveis">
                <input id="txtAuxOrcamento" runat="server" type="text" class="variaveis" />
                <div id="divGeneratePDF"></div>
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
    <script type="text/javascript" src="../printthis/printThis.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.8.0/js/bootstrap-datepicker.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.8.0/locales/bootstrap-datepicker.pt.min.js"></script>

    <script>
        var ordCliente = 0;
        var ordViatura = 0;
        var ordData = 0;
        var ordDescricao = 0;
        var ordTipo = 0;
        var administrador;

        $(document).ready(function () {
            loga();
            setAltura();
            getTotals();
            setInterval(function () {
                getTotals();
            }, 5000);

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
                    setDatePicker();
                    getData();

                    if (administrador == 0) {
                        $('#divBtnCreate').fadeOut();
                    }
                    else {
                        $('#divBtnCreate').fadeIn();
                    }
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

        // Web services

        function getData() {
            loadingOn('A carregar as reparações. Por favor aguarde...');
            var pesquisa = $('#txtPesquisa').val();
            var order = "";
            var orcamento = $('#txtAuxOrcamento').val();
            var initialDate = $('#txtDataInicial').val();
            var finalDate = $('#txtDataFinal').val();

            if (ordCliente == 0 && ordViatura == 0 && ordData == 0 && ordDescricao == 0 && ordTipo == 0) {
                order = ' ORDER BY data_manutencao desc, marca asc, modelo asc, matricula asc ';
            }
            else {
                order = ' ORDER BY ';

                if (ordCliente != 0) {
                    order += ordCliente == -1 ? ' cliente desc ' : ' cliente asc ';
                }
                else if (ordViatura != 0) {
                    order += ordViatura == -1 ? ' marca desc, modelo desc, matricula desc ' : ' marca asc, modelo asc, matricula asc ';
                }
                else if (ordData != 0) {
                    order += ordData == -1 ? ' data_manutencao desc ' : ' data_manutencao asc ';
                }
                else if (ordDescricao != 0) {
                    order += ordDescricao == -1 ? ' descricao desc ' : ' ordDescricao asc ';
                }
                else if (ordTipo != 0) {
                    order += ordTipo == -1 ? ' mecanica desc, batechapas desc ' : ' mecanica asc, batechapas asc ';
                }
            }

            $.ajax({
                type: "POST",
                url: "lista_manutencoes.aspx/getGrelha",
                data: '{"pesquisa":"' + pesquisa + '","order":"' + order + '","admin":"' + administrador + '","orcamento":"' + orcamento + '","initialDate":"' + initialDate + '","finalDate":"' + finalDate + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    $('#divGrelhaRegistos').html(res.d);
                    getTotals();
                    defineValues();
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
            loadUrl('config_ficha_manutencao.aspx?id=' + id + '&orcamento=0');
        }

        function eliminar(id) {
            var orcamento = $('#txtAuxOrcamento').val();
            var warningTitle = orcamento == "1" ? "Eliminar Orçamento" : "Eliminar Reparação";
            var warningText = orcamento == "1" ? "O orçamento será eliminado. Confirma?" : "A reparação será eliminada. Confirma?";

            swal({
                title: warningTitle,
                text: warningText,
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
                url: "lista_manutencoes.aspx/delRow",
                data: '{"id":"' + id + '","idUser":"' + localStorage.loga + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var res = dados[0];
                    var resMsg = dados[1];

                    if (parseInt(res) <= 0) {
                        var orcamento = $('#txtAuxOrcamento').val();
                        var warningTitle = orcamento == "1" ? "Eliminar Orçamento" : "Eliminar Reparação";
                        sweetAlertWarning(warningTitle, resMsg);
                    }
                    else {
                        $('#txtPesquisa').val('');
                        ordCliente = 0;
                        ordViatura = 0;
                        ordData = 0;
                        ordDescricao = 0;
                        ordTipo = 0;
                        getData();
                    }
                }
            });
        }

        function novo() {
            loadUrl('config_ficha_manutencao.aspx?orcamento=' + $('#txtAuxOrcamento').val());
        }

        function generatePDF(id) {
            var orcamento = $('#txtAuxOrcamento').val();

            $.ajax({
                type: "POST",
                url: "lista_manutencoes.aspx/generatePDF",
                data: '{"idUser":"' + localStorage.loga + '","id":"' + id + '","orcamento":"' + orcamento + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var nomeficheiro = dados[0];
                    var header = dados[1];
                    var footer = dados[2];
                    var body = dados[3];
                    var title = dados[4];
                    //var file = dados[1];
                    $('#divGeneratePDF').html(body);
                    createPDF('contacorrente/' + nomeficheiro, title, header, footer);
                }
            });
        }

        function visualizar(id) {
            var orcamento = $('#txtAuxOrcamento').val();

            if (orcamento == '' || orcamento.length === 0) {
                orcamento = '0';
            }

            var title = orcamento == "1" ? "<strong>DADOS DO ORÇAMENTO</strong>" : "<strong>DADOS DA REPARAÇÃO</strong>";
            var tipo = orcamento == "1" ? "ORÇAMENTOS" : "REPARAÇÕES";

            $.ajax({
                type: "POST",
                url: "index.aspx/generateViewInfo",
                data: '{"idUser":"' + localStorage.loga + '","id":"' + id + '","tipo":"' + tipo + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d;

                    swal({
                        title: title,
                        html: dados,
                        showCancelButton: false,
                        confirmButtonColor: "#DD6B55",
                        confirmButtonText: "OK"
                    }).then(function () {

                    });
                }
            });
        }

        function ordenaCliente() {
            ordViatura = 0;
            ordData = 0;
            ordDescricao = 0;
            ordTipo = 0;

            if (ordCliente == 0) {
                ordCliente = 1;
            }
            else {
                ordCliente = ordCliente * (-1);
            }

            getData();
        }

        function ordenaViatura() {
            ordCliente = 0;
            ordData = 0;
            ordDescricao = 0;
            ordTipo = 0;

            if (ordViatura == 0) {
                ordViatura = 1;
            }
            else {
                ordViatura = ordViatura * (-1);
            }

            getData();
        }

        function ordenaData() {
            ordViatura = 0;
            ordCliente = 0;
            ordDescricao = 0;
            ordTipo = 0;

            if (ordData == 0) {
                ordData = 1;
            }
            else {
                ordData = ordData * (-1);
            }

            getData();
        }

        function ordenaDescricao() {
            ordViatura = 0;
            ordData = 0;
            ordCliente = 0;
            ordTipo = 0;

            if (ordDescricao == 0) {
                ordDescricao = 1;
            }
            else {
                ordDescricao = ordDescricao * (-1);
            }

            getData();
        }

        function ordenaTipo() {
            ordViatura = 0;
            ordData = 0;
            ordDescricao = 0;
            ordCliente = 0;

            if (ordTipo == 0) {
                ordTipo = 1;
            }
            else {
                ordTipo = ordTipo * (-1);
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

        function defineValues() {
            var title = "";
            var btn = "<span id='spanBtnCreate'><i class='fa fa-wrench' aria-hidden='true'></i>[BTN_TEXT]<i class='fa fa-paint-brush' aria-hidden='true'></i></span>";
            if ($('#txtAuxOrcamento').val() == '1') {
                title = "Orçamentos";
                btn = btn.replace('[BTN_TEXT]', '  Criar novo orçamento  ');
            }
            else {
                title = "Reparações";
                btn = btn.replace('[BTN_TEXT]', '  Criar nova reparação  ');
            }

            $('#tableTitle').html(title);
            $('#btnCreate').html(btn);
            $('#title').html(title);
        }

        //Create PDf from HTML...
        function createPDF(filename, title, header, footer) {
            $('#divGeneratePDF').printThis({
                debug: true,               // show the iframe for debugging
                importCSS: true,            // import parent page css
                importStyle: true,          // import style tags
                printContainer: true,       // print outer container/$.selector
                //loadCSS: "",                // path to additional css file - use an array [] for multiple
                pageTitle: title,              // add title to print page
                //removeInline: false,        // remove inline styles from print elements
                //removeInlineSelector: "*",  // custom selectors to filter inline styles. removeInline must be true
                //printDelay: 1000,           // variable print delay
                header: header,               // prefix to html
                footer: footer,               // postfix to html
                //base: false,                // preserve the BASE tag or accept a string for the URL
                //formValues: true,           // preserve input/form values
                //canvas: true,              // copy canvas content
                //doctypeString: null,       // enter a different doctype for older markup
                removeScripts: false,       // remove script tags from print content
                copyTagClasses: true,       // copy classes from the html & body tag
                copyTagStyles: true,        // copy styles from html & body tag (for CSS Variables)
                beforePrintEvent: null,     // function for printEvent in iframe
                beforePrint: null,          // function called before iframe is filled
                afterPrint: null            // function called before iframe is removed
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

        function setDatePicker() {
            var initialDate;
            var FinalDate;
            var initialDateSplit;
            var finalDateSplit;
            var initialDateToBeUsed = $('#txtDataInicial').val();
            var finalDateToBeUsed = $('#txtDataFinal').val();

            initialDateSplit = initialDateToBeUsed.split('/');
            finalDateSplit = finalDateToBeUsed.split('/');

            initialDate = new Date(initialDateSplit[2], initialDateSplit[1] - 1, initialDateSplit[0]);
            FinalDate = new Date(finalDateSplit[2], finalDateSplit[1] - 1, finalDateSplit[0]);

            $('#txtDataInicial').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtDataInicial').datepicker('setDate', initialDate).on('changeDate', function (e) {
                getData();
            });
            $('#txtDataInicial').val(initialDateToBeUsed);

            $('#txtDataFinal').datepicker({ format: 'dd/mm/yyyy', changeYear: true, changeMonth: true, orientation: 'auto top', autoclose: true });
            $('#txtDataFinal').datepicker('setDate', FinalDate).on('changeDate', function (e) {
                getData();
            });
            $('#txtDataFinal').val(finalDateToBeUsed);
        }
    </script>
</body>

</html>
