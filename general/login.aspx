<%@ Page Language="C#" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="login" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Grilo Car Service Software - Login">
    <meta name="author" content="André Lourenço">
    <title>GRILO CAR SERVICE - Login</title>
    <!-- Favicon -->
    <link href="../Img/favicon.ico" rel="icon" type="image/ico">
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
    <!-- Icons -->
    <link href="assets/vendor/nucleo/css/nucleo.css" rel="stylesheet">
    <link href="assets/vendor/@fortawesome/fontawesome-free/css/all.min.css" rel="stylesheet">
    <!-- Argon CSS -->
    <link type="text/css" href="assets/css/argon.css?v=1.0.1" rel="stylesheet">
    <link href="../vendors/sweetalert2/sweetalert2.min.css" rel="stylesheet" />

    <style>
        .bg-gradient-primary {
            background: linear-gradient(87deg, #E3101A 0, white 100%) !important;
        }

        .fill-default {
            fill: #E3101A;
        }
    </style>
</head>

<body class="bg-default" style="background-color: #E3101A!important">
    <div class="main-content">
        <!-- Header -->
        <div class="header bg-gradient-primary py-7 py-lg-8">
            <div class="container">
                <div class="header-body text-center mb-7">
                    <div class="row justify-content-center">
                        <div class="col-lg-12 col-md-12">
                            <h1 class="text-white">BEM-VINDO!</h1>
                            <p class="text-lead text-white">Bem-vindo à area de administração da GRILO CAR SERVICE!</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="separator separator-bottom separator-skew zindex-100">
                <svg x="0" y="0" viewBox="0 0 2560 100" preserveAspectRatio="none" version="1.1" xmlns="http://www.w3.org/2000/svg">
                    <polygon class="fill-default" points="2560 0 2560 100 0 100"></polygon>
                </svg>
            </div>
        </div>
        <!-- Page content -->
        <div class="container mt--8 pb-5">
            <div class="row justify-content-center">
                <div class="col-lg-5 col-md-7">
                    <div class="card bg-secondary shadow border-0">

                        <div class="card-body px-lg-5 py-lg-5">
                            <div class="text-center text-muted mb-4">
                                <img src="../Img/logo.png" style="width:100%; height: auto;"/>
                            </div>
                            <div class="text-center text-muted mb-4">
                                <small>Por favor introduza os seus dados de acesso</small>
                            </div>
                            <form role="form">
                                <div class="form-group mb-3">
                                    <div class="input-group input-group-alternative">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><i class="fa fa-user"></i></span>
                                        </div>
                                        <input id="txtU" class="form-control" placeholder="Username" type="text">
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="input-group input-group-alternative">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><i class="ni ni-lock-circle-open"></i></span>
                                        </div>
                                        <input id="txtP" class="form-control" placeholder="Password" type="password">
                                    </div>
                                </div>
                                <%-- <div class="custom-control custom-control-alternative custom-checkbox">
                  <input class="custom-control-input" id=" customCheckLogin" type="checkbox">
                  <label class="custom-control-label" for=" customCheckLogin">
                    <span class="text-muted">Lembrar</span>
                  </label>
                </div>--%>
                                <div class="text-center">
                                    <button type="button" class="btn btn-primary my-4" onclick="entra();">Entrar</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-6">
                            <a href="#" class="text-light" style="display: none"><small>Esqueceu-se da password?</small></a>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Argon Scripts -->
    <!-- Core -->
    <script src="assets/vendor/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Argon JS -->
    <script src="assets/js/argon.js?v=1.0.0"></script>
    <script src="../vendors/sweetalert2/sweetalert2.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>

    <script type="text/javascript">

        $(document).ready(function () {
            localStorage.setItem("loga", null);
            $('#txtU').focus();
        });

        $(document).keypress(function (e) {
            if (e.which == 13) {
                if ($("#txtU").is(":focus")) {
                    $("#txtP").focus();
                }
                else if ($("#txtP").is(":focus")) {
                    entra();
                }
            }
        });

        function entra() {
            var u = $('#txtU').val();
            var p = $('#txtP').val();

            if (u == '' || u == null || u == undefined) {
                sweetAlertInfo("Email", "Por favor introduza o endereço de email.");
                return;
            }

            if (p == '' || p == null || p == undefined) {
                sweetAlertInfo("Password", "Por favor introduza a password.");
                return;
            }

            if (u != '' && u != null && u != undefined && p != '' && p != null && p != undefined) {
                $.ajax({
                    type: "POST",
                    url: "login.aspx/entra",
                    data: '{"u":"' + u + '","p":"' + p + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var dados = res.d.split('<#SEP#>');
                        var ret = parseInt(dados[0]);
                        var retMsg = dados[1];

                        if (ret > 0) {
                            localStorage.setItem("loga", ret);

                            window.location = '../admin/index.aspx';
                        }
                        else {
                            localStorage.setItem("loga", null);

                            if (ret == -500) {
                                window.location = retMsg;
                            }
                            else {
                                sweetAlertInfo("Login", retMsg);

                                $('#txtU').val('');
                                $('#txtP').val('');
                            }
                        }
                    }
                });
            }
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
