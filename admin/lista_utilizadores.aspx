<%@ Page Language="C#" AutoEventWireup="true" CodeFile="lista_utilizadores.aspx.cs" Inherits="lista_utilizadores" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="CASHDRO Software - Lista de Utilizadores">
    <meta name="author" content="André Lourenço | Márcio Borges">
    <title>CASHDRO - Lista de Utilizadores</title>
    <!-- Favicon -->
    <link href="../general/assets/img/brand/favicon.png" rel="icon" type="image/png">
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
    <!-- Icons -->
    <link href="../general/assets/vendor/nucleo/css/nucleo.css" rel="stylesheet">
    <link href="../general/assets/vendor/@fortawesome/fontawesome-free/css/all.min.css" rel="stylesheet">
    <!-- Argon CSS -->
    <link type="text/css" href="../general/assets/css/argon.css?v=1.0.0" rel="stylesheet">
    <link href="../vendors/sweetalert2/sweetalert2.min.css" rel="stylesheet" />

    <style type="text/css">
        .myselect {
            background: none repeat scroll 0 0 #FFFFFF;
            border: 1px solid #E5E5E5;
            border-radius: 5px 5px 5px 5px;
            box-shadow: 0 0 10px #E8E8E8 inset;
            height: 40px;
            margin: 0 0 0 25px;
            padding: 10px;
            width: 110px;
            font-size: 14px;
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
    </style>
</head>

<body>

    <!-- Main content -->
    <div class="main-content">
        <!-- Top navbar -->
        <nav class="navbar navbar-top navbar-expand-md navbar-dark" id="navbar-main">
            <div class="container-fluid">
                <!-- Brand -->
                <a class="h4 mb-0 text-white text-uppercase d-none d-lg-inline-block">Utilizadores</a>
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
        <div class="header bg-gradient-primary pb-8 pt-5 pt-md-8" id="divInfo">
            <div class="container-fluid">
                <div class="header-body">
                    <!-- Card stats -->
                </div>
            </div>

            <div class="container-fluid d-flex align-items-center">
                <div class="row">
                    <div class="col-lg-12 col-md-10">
                        <h1 class="display-2 text-white">Utilizadores</h1>
                        <p class="text-white mt-0 mb-5">Parametrize os utilizadores com acesso ao sistema.</p>
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
                                    <td style="width: 50%; max-width: 50% !important">
                                        <h3 class="mb-0">Utilizadores</h3>
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
                                    <td style="width: 15%; text-align: right;">
                                        <div>
                                            <a class="btn btn-sm btn-primary" onclick="novo();" style="color: #FFFFFF;" id="btnCreateUser">
                                                <span id="spanBtnCriaUtilizadorAlteraStatus"><i class="fa fa-user" aria-hidden="true"></i>  Criar Novo Utilizador</span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="table-responsive" id="divGrelha">
                            <div id="divGrelhaRegistos"></div>
                        </div>

                    </div>
                </div>
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
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>

    <script>
        var ordNome = 0;
        var ordCodigo = 0;
        var ordAdmin = 0;
        var ordPerfil = 0;
        var ordAtivo = 0;
        var administrador;

        $(document).ready(function () {
            loga();
            setAltura();
            $("#txtPesquisa").focus();
            getData();
            defineTablesMaxHeight();
        });

        $(window).resize(function () {
            setAltura();
            defineTablesMaxHeight();
        });

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

        function keyPesquisa(e) {
            if (e.keyCode == 13) {
                getData();
            }
        }

        function novo() {
            window.location = "config_ficha_utilizador.aspx";
        }

        function editar(id) {
            window.location = "config_ficha_utilizador.aspx?id=" + id;
        }

        function loga() {
            var id = localStorage.loga;
            $('#txtAux').val(id);

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

                    if (administrador == 0) {
                        $('#btnCreateUser').fadeOut();
                    }
                    else {
                        $('#btnCreateUser').fadeIn();
                    }
                }
            });
        }

        function apaga(id) {
            swal({
                title: 'Eliminar utilizador',
                text: "O utilizador será eliminado. Confirma?",
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

        function loadUrl(url) {
            window.location = url;
        }

        function finishSession() {
            window.top.location = "../general/login.aspx";
        }

        // Web services
        function delRow(id) {
            $.ajax({
                type: "POST",
                url: "lista_utilizadores.aspx/delRow",
                data: '{"id":"' + id + '","idUser":"' + localStorage.loga + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');
                    var res = dados[0];
                    var resMsg = dados[1];

                    if (parseInt(res) <= 0) {
                        sweetAlertWarning("Eliminar utilizador", resMsg);
                    }
                    else {
                        $('#txtPesquisa').val('');
                        ordNome = 0;
                        ordCodigo = 0;
                        ordAdmin = 0;
                        ordPerfil = 0;
                        ordAtivo = 0;
                        getData();
                    }
                }
            });
        }

        function getData() {
            $("#txtPesquisa").focus();
            var pesquisa = $('#txtPesquisa').val();
            var order = "";

            if (ordNome == 0 && ordCodigo == 0 && ordAdmin == 0 && ordPerfil == 0 && ordAtivo == 0) {
                order = ' ORDER BY administrador desc, nome asc ';
            }
            else {
                order = ' ORDER BY ';

                if (ordNome != 0) {
                    order += ordNome == -1 ? ' nome desc ' : ' nome asc ';
                }
                else if (ordCodigo != 0) {
                    order += ordCodigo == -1 ? ' codigo desc ' : ' codigo asc ';
                }
                else if (ordAdmin != 0) {
                    order += ordAdmin == -1 ? ' administrador desc ' : ' administrador asc ';
                }
                else if (ordPerfil != 0) {
                    order += ordPerfil == -1 ? ' tipo desc ' : ' tipo asc ';
                }
                else if (ordAtivo != 0) {
                    order += ordAtivo == -1 ? ' ativo desc ' : ' ativo asc ';
                }
            }

            $.ajax({
                type: "POST",
                url: "lista_utilizadores.aspx/getGrelha",
                data: '{"pesquisa":"' + pesquisa + '","order":"' + order + '","idUser":"' + localStorage.loga + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    $('#divGrelhaRegistos').html(res.d);
                }
            });
        }

        function ordenaNome() {
            ordCodigo = 0;
            ordAdmin = 0;
            ordPerfil = 0;
            ordAtivo = 0;

            if (ordNome == 0) {
                ordNome = 1;
            }
            else {
                ordNome = ordNome * (-1);
            }

            getData();
        }

        function ordenaCodigo() {
            ordNome = 0;
            ordAdmin = 0;
            ordPerfil = 0;
            ordAtivo = 0;

            if (ordCodigo == 0) {
                ordCodigo = 1;
            }
            else {
                ordCodigo = ordCodigo * (-1);
            }

            getData();
        }

        function ordenaAdmin() {
            ordNome = 0;
            ordCodigo = 0;
            ordPerfil = 0;
            ordAtivo = 0;

            if (ordAdmin == 0) {
                ordAdmin = 1;
            }
            else {
                ordAdmin = ordAdmin * (-1);
            }

            getData();
        }

        function ordenaPerfil() {
            ordNome = 0;
            ordCodigo = 0;
            ordAdmin = 0;
            ordAtivo = 0;

            if (ordPerfil == 0) {
                ordPerfil = 1;
            }
            else {
                ordPerfil = ordPerfil * (-1);
            }

            getData();
        }

        function ordenaAtivo() {
            ordNome = 0;
            ordCodigo = 0;
            ordAdmin = 0;
            ordPerfil = 0;

            if (ordAtivo == 0) {
                ordAtivo = 1;
            }
            else {
                ordAtivo = ordAtivo * (-1);
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
    </script>
</body>

</html>
