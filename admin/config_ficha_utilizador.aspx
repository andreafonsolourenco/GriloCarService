<%@ Page Language="C#" AutoEventWireup="true" CodeFile="config_ficha_utilizador.aspx.cs" Inherits="config_ficha_utilizador" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="CASHDRO Software - Ficha do Utilizador">
    <meta name="author" content="André Lourenço | Márcio Borges">
    <title>CASHDRO - Ficha do Utilizador</title>
    <!-- Favicon -->
    <link href="../general/assets/img/brand/favicon.png" rel="icon" type="image/png">
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
    <!-- Icons -->
    <link href="../general/assets/vendor/nucleo/css/nucleo.css" rel="stylesheet">
    <link href="../general/assets/vendor/@fortawesome/fontawesome-free/css/all.min.css" rel="stylesheet">
    <!-- Argon CSS -->
    <link type="text/css" href="../general/assets/css/argon.css?v=1.0.0" rel="stylesheet">
    <link href="../general/assets/css/mbs_div.css" rel="stylesheet" />
    <link href="../vendors/sweetalert2/sweetalert2.min.css" rel="stylesheet" />
    <link type="text/css" href="../alertify/css/alertify.min.css" rel="stylesheet" />
    <link type="text/css" href="../alertify/css/themes/default.min.css" rel="stylesheet" />

    <style>
        .bg-gradient-primary {
            background: linear-gradient(87deg, #004D95, #004D95 100%) !important;
        }

        .col-xl-8 {
            max-width: 99%;
            flex: 0 0 99%;
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
        <div class="header pb-8 pt-5 pt-lg-8 d-flex align-items-center" style="min-height: 200px; background-size: cover; background-position: center top;" id="divInfo">
            <!-- Mask -->
            <span class="mask bg-gradient-primary opacity-8"></span>
            <!-- Header container -->
            <div class="container-fluid d-flex align-items-center">
                <div class="row">
                    <div class="col-lg-12 col-md-10">
                        <h1 class="display-2 text-white">Utilizadores</h1>
                        <p class="text-white mt-0 mb-5">Crie/edite os dados de utilizador</p>
                        <a href="#!" class="btn btn-default" onclick="confirmSave();">Guardar alterações</a>
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
                                            <h3 class="mb-0">Utilizadores</h3>
                                        </td>
                                        <td style="width: 10%; text-align: right">
                                            <img src='../general/assets/img/theme/setae.png' style='width: 30px; height: 30px; cursor: pointer' alt='Back' title='Back' onclick='retroceder();'/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="card-body" id="divGrelha">
                            <form>
                                <h6 class="heading-small text-muted mb-4">Informação de utilização</h6>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label class="form-control-label" for="txtNome">Nome</label>
                                            <input type="text" id="txtNome" class="form-control form-control-alternative" placeholder="Nome">
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12" id="divTipoUtilizador" runat="server"></div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="form-control-label" for="txtEmail">Email</label>
                                            <input type="text" id="txtEmail" class="form-control form-control-alternative" placeholder="Email">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="form-control-label" for="txtTelemovel">Telemóvel</label>
                                            <input type="text" id="txtTelemovel" class="form-control form-control-alternative" placeholder="Telemóvel">
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-5">
                                        <div class="form-group">
                                            <label class="form-control-label" for="txtCodigo">Código</label>
                                            <input type="text" id="txtCodigo" class="form-control form-control-alternative" placeholder="Código">
                                        </div>
                                    </div>
                                    <div class="col-md-5" id="divPassword">
                                        <div class="form-group">
                                            <label class="form-control-label" for="txtPassword">Password</label>
                                            <input type="password" id="txtPassword" class="form-control form-control-alternative" placeholder="Password">
                                        </div>
                                    </div>
                                    <div class="col-md-2" id="divShowPass">
                                        <div class="custom-control custom-control-alternative custom-checkbox" style="top: 25%;">
                                            <input class="custom-control-input" id="chkShowPass" type="checkbox" onclick="showPass();">
                                            <label class="custom-control-label" for="chkShowPass">
                                                <span class="text-muted">Ver Pass</span>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label class="form-control-label" for="txtNotas">Observações</label>
                                            <textarea id="txtNotas" rows="3" style="resize: none" class="form-control form-control-alternative" placeholder="Observações diversas"></textarea>
                                        </div>
                                    </div>
                                </div>


                                <hr class="my-4" />
                                <!-- Description -->
                                <h6 class="heading-small text-muted mb-4">Estado</h6>

                                <div class="row" style="padding-left: 0px">
                                    <div class="col-md-6">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkAtivo" type="checkbox" checked>
                                            <label class="custom-control-label" for="chkAtivo">
                                                <span class="text-muted">Ativo</span>
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="custom-control custom-control-alternative custom-checkbox">
                                            <input class="custom-control-input" id="chkAdmin" type="checkbox" disabled checked>
                                            <label class="custom-control-label" for="chkAdmin">
                                                <span class="text-muted">Administrador</span>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </form>
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
    

    <script>
        var administrador;

        $(document).ready(function () {
            loga();
            setAltura();
            getData();
        });

        $(window).resize(function () {
            setAltura();
        });

        function setAltura() {
            $("#fraContent").height($(window).height());
        }

        function showPopup(id) {
            document.getElementById(id).style.display = 'block';
        }

        function hidePopup(id) {
            document.getElementById(id).style.display = 'none';
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

        function verifyUserType() {
            $.ajax({
                type: "POST",
                url: "config_ficha_utilizador.aspx/checkAdmin",
                data: '{"id_tipo":"' + $('#ddlTipo').val() + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var admin = res.d;

                    if (admin == "false") {
                        $('#chkAdmin').attr('checked', false);
                    }
                    else {
                        $('#chkAdmin').attr('checked', true);
                    }
                }
            });
        }

        function finishSession() {
            window.top.location = "../general/login.aspx";
        }

        function getData() {
            var id = $('#txtAux').val();
            if (id != null && id != 'null' && id != '' && id != '0') {
                $.ajax({
                    type: "POST",
                    url: "config_ficha_utilizador.aspx/getData",
                    data: '{"id":"' + id + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var dados = res.d.split('<#SEP#>');

                        var nome = dados[0];
                        var codigo = dados[1];
                        var email = dados[2];
                        var password = dados[3];
                        var telemovel = dados[4];
                        var notas = dados[5];
                        var id_tipo = dados[6];
                        var tipo = dados[7];
                        var ativo = dados[8];
                        var admin = dados[9];

                        $("#ddlTipo option[value=" + id_tipo + "]").attr('selected', 'selected');
                        $('#txtNome').val(nome);
                        $('#txtEmail').val(email);
                        $('#txtPassword').val(password);
                        $('#txtTelemovel').val(telemovel);
                        $('#txtNotas').val(notas);
                        $('#txtCodigo').val(codigo);

                        if (ativo == "false")
                            $('#chkAtivo').attr('checked', false);
                        else
                            $('#chkAtivo').attr('checked', true);

                        if (admin == "false")
                            $('#chkAdmin').attr('checked', false);
                        else
                            $('#chkAdmin').attr('checked', true);

                        $('#chkShowPass').attr('checked', false);

                        if (administrador == 0) {
                            $('#ddlTipo').attr('disabled', true);
                        }
                        else {
                            $('#ddlTipo').attr('disabled', false);
                        }
                    }
                });
            }
            else {
                $('#txtNome').val('');
                $('#txtEmail').val('');
                $('#txtPassword').val('');
                $('#txtTelemovel').val('');
                $('#txtNotas').val('');
                $('#txtCodigo').val('');

                $('#chkAtivo').attr('checked', true);
                $('#chkAdmin').attr('checked', true);
                $('#chkShowPass').attr('checked', false);
            }

            $('#divShowPass').height($('#divPassword').height());
        }

        function saveData() {
            var id = $('#txtAux').val();

            var nome = $('#txtNome').val();
            var email = $('#txtEmail').val();
            var password = $('#txtPassword').val();
            var tlm = $('#txtTelemovel').val();
            var notas = $('#txtNotas').val();
            var codigo = $('#txtCodigo').val();
            var id_tipo = $('#ddlTipo').val();

            var ativo = $('#chkAtivo').is(":checked");
            if (ativo) ativo = 1;
            else ativo = 0;

            var admin = $('#chkAdmin').is(":checked");
            if (admin) admin = 1;
            else admin = 0;

            if (nome == '' || nome == null || nome == undefined) {
                sweetAlertWarning('Nome', 'Por favor indique o nome do utilizador');
                return;
            }
            else if (email == '' || email == null || email == undefined) {
                sweetAlertWarning('Email', 'Por favor indique o endereço de email');
                return;
            }
            else if (password == '' || password == null || password == undefined) {
                sweetAlertWarning('Password', 'Por favor indique a password de acesso');
                return;
            }
            else if (id_tipo == '' || id_tipo == null || id_tipo == undefined || parseInt(id_tipo) <= 0) {
                sweetAlertWarning('Tipo', 'Por favor indique o tipo de utilizador');
                return;
            }
            else if (tlm == '' || tlm == null || tlm == undefined) {
                sweetAlertWarning('Telemóvel', 'Por favor indique o telemóvel');
                return;
            }
            else if (codigo == '' || codigo == null || codigo == undefined) {
                sweetAlertWarning('Código', 'Por favor indique o código de utilizador');
                return;
            }

            $.ajax({
                type: "POST",
                url: "config_ficha_utilizador.aspx/saveData",
                data: '{"id":"' + id + '","nome":"' + nome + '","email":"' + email + '","password":"' + password + '","tlm":"' + tlm
                    + '","notas":"' + notas + '","ativo":"' + ativo + '","codigo":"' + codigo + '","id_tipo":"' + id_tipo + '","idUser":"' + localStorage.loga + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');

                    if (parseInt(dados[0]) > 0) {
                        loadUrl('lista_utilizadores.aspx');
                    }
                    else {
                        sweetAlertWarning('Aviso', dados[1]);
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
                    loadUrl('lista_utilizadores.aspx');
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

        function showPass() {
            var x = document.getElementById("txtPassword");
            if (x.type === "password") {
                x.type = "text";
            } else {
                x.type = "password";
            }
        }

        function sweetAlertWarning(subject, msg) {
            swal(
                subject,
                msg,
                'warning'
            )
        }
    </script>
</body>

</html>
