<%@ Page Language="C#" AutoEventWireup="true" CodeFile="config_ficha_cliente.aspx.cs" Inherits="config_ficha_cliente" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Grilo Car Service Software - Ficha de Cliente">
    <meta name="author" content="André Lourenço">
    <title>Grilo Car Service Software - Ficha de Cliente</title>
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
                <a class="h4 mb-0 text-white text-uppercase d-none d-lg-inline-block">Clientes</a>
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
                        <h1 class="display-2 text-white" id="divInfoTitle">Clientes</h1>
                        <p class="text-white mt-0 mb-5" id="divInfoSubTitle">Crie/Edite os Clientes</p>
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
                                            <h3 class="mb-0" id="sectionTitle">Clientes</h3>
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
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtName">Nome</label>
                                        <input type="text" id="txtName" class="form-control form-control-alternative" placeholder="Nome">
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtAddress">Morada</label>
                                        <input type="text" id="txtAddress" class="form-control form-control-alternative" placeholder="Morada">
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtZipCode">Código Postal</label>
                                        <input type="text" id="txtZipCode" class="form-control form-control-alternative" placeholder="Código Postal">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCity">Localidade</label>
                                        <input type="text" id="txtCity" class="form-control form-control-alternative" placeholder="Localidade">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCountry">País</label>
                                        <input type="text" id="txtCountry" class="form-control form-control-alternative" placeholder="País">
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtEmail">Email</label>
                                        <input type="email" id="txtEmail" class="form-control form-control-alternative" placeholder="Email">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtCity">Telemóvel</label>
                                        <input type="text" id="txtPhone" class="form-control form-control-alternative" placeholder="Telemóvel">
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-8" id="divNIF">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtNIF">NIF</label>
                                        <input type="text" id="txtNIF" class="form-control form-control-alternative" placeholder="NIF" onfocusout="checkCustomerOrCar();">
                                    </div>
                                </div>
                                <div class="col-md-4" id="divAtivo">
                                    <div class="custom-control custom-control-alternative custom-checkbox" style="top: 25%;">
                                        <input class="custom-control-input" id="chkAtivo" type="checkbox" checked>
                                        <label class="custom-control-label" for="chkAtivo">
                                            <span class="text-muted">Ativo</span>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="form-control-label" for="txtNotes">Notas</label>
                                        <textarea type='text' id='txtNotes' class='form-control form-control-alternative auto_height' oninput='auto_height(this)' placeholder='Notas'></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
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
        });

        $(window).resize(function () {
            setAltura();
        });

        $(document).keypress(function (e) {
            if (e.which == 13) {
                
            }
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

        function defineTablesMaxHeight() {
            var windowHeight = $(window).height();
            var divInfoHeight = $('#divInfo').height();
            var navbarHeight = $('#navbar-main').height();
            var maxHeight = windowHeight - divInfoHeight - navbarHeight - 200;

            $('#divGrelha').css({ "maxHeight": maxHeight + "px" });
        }

        function getData() {
            loadingOn('A carregar dados!<br />Por favor aguarde...');
            var id = $('#txtAux').val();
            if (id != null && id != 'null' && id != '') {
                $.ajax({
                    type: "POST",
                    url: "config_ficha_cliente.aspx/getData",
                    data: '{"id":"' + id + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var dados = res.d.split('<#SEP#>');

                        // Prepara o retorno dos dados
                        var nome = dados[0];
                        var morada = dados[1];
                        var localidade = dados[2];
                        var codpostal = dados[3];
                        var nif = dados[4];
                        var email = dados[5];
                        var telemovel = dados[6];
                        var notas = dados[7];
                        var pais = dados[8];
                        var s_ativo = dados[9];

                        $('#txtName').val(nome);
                        $('#txtAddress').val(morada);
                        $('#txtZipCode').val(codpostal);
                        $('#txtCity').val(localidade);
                        $('#txtEmail').val(email);
                        $('#txtPhone').val(telemovel);
                        $('#txtNIF').val(nif);
                        $('#txtNotes').val(notas);
                        $('#txtCountry').val(pais);

                        if (s_ativo == "false")
                            $('#chkAtivo').attr('checked', false);
                        else
                            $('#chkAtivo').attr('checked', true);

                        loadingOff();
                    }
                });
            }
            else {
                $('#txtName').val('');
                $('#txtAddress').val('');
                $('#txtZipCode').val('');
                $('#txtCity').val('');
                $('#txtEmail').val('');
                $('#txtPhone').val('');
                $('#txtNIF').val('');
                $('#txtNotes').val('');
                $('#txtCountry').val('Portugal');

                $('#chkAtivo').attr('checked', true);
                loadingOff();
            }

            $('#divAtivo').height($('#divNIF').height());
        }

        function saveData() {
            var id = $('#txtAux').val();
            var name = $('#txtName').val();
            var address = $('#txtAddress').val();
            var zipCode = $('#txtZipCode').val();
            var city = $('#txtCity').val();
            var nif = $('#txtNIF').val();
            var email = $('#txtEmail').val();
            var phone = $('#txtPhone').val();
            var notes = $('#txtNotes').val();
            var country = $('#txtCountry').val();
            var active = $("#chkAtivo").is(":checked") ? '1' : '0';

            if (id == null || id == 'null' || id == '') {
                id = '0';
            }

            if (name == '' || name == null || name == undefined) {
                sweetAlertWarning('Nome', 'Por favor indique o nome');
                return;
            }
            else if (address == '' || address == null || address == undefined) {
                sweetAlertWarning('Morada', 'Por favor indique a morada');
                return;
            }
            else if (zipCode == '' || zipCode == null || zipCode == undefined) {
                sweetAlertWarning('Código Postal', 'Por favor indique o código postal');
                return;
            }
            else if (city == '' || city == null || city == undefined) {
                sweetAlertWarning('Localidade', 'Por favor indique a localidade');
                return;
            }
            else if (!validaNIF(nif)) {
                sweetAlertWarning('NIF', 'Por favor indique um NIF válido');
                return;
            }
            else if (country == '' || country == null || country == undefined) {
                sweetAlertWarning('País', 'Por favor indique o país');
                return;
            }

            $.ajax({
                type: "POST",
                url: "config_ficha_cliente.aspx/saveData",
                data: '{"idUser":"' + localStorage.loga + '","id":"' + id + '","name":"' + name + '","address":"' + address + '","zipCode":"' + zipCode + '","city":"' + city + '","nif":"' + nif +
                    '","email":"' + email + '","phone":"' + phone + '","notes":"' + notes + '","country":"' + country + '","active":"' + active + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var dados = res.d.split('<#SEP#>');

                    if (parseInt(dados[0]) < 0) {
                        sweetAlertError(title, dados[1]);
                    }
                    else {
                        loadUrl("lista_clientes.aspx");
                    }
                }
            });
        }

        function validaNIF(value) {
            value = value + "";

            // has 9 digits?
            if (!/^[0-9]{9}$/.test(value)) return false;

            // is from a person?
            if (!/^[123]|45|5/.test(value)) return false;

            //// digit check
            //let tot =
            //    value[0] * 9 +
            //    value[1] * 8 +
            //    value[2] * 7 +
            //    value[3] * 6 +
            //    value[4] * 5 +
            //    value[5] * 4 +
            //    value[6] * 3 +
            //    value[7] * 2;
            //let div = tot / 11;
            //let mod = tot - parseInt(div) * 11;
            //let tst = mod == 1 || mod == 0 ? 0 : 11 - mod;
            //return value[8] == tst;

            return true;
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
                    loadUrl('lista_clientes.aspx');
                }
            });
        }

        function confirmSave() {
            swal({
                title: "GUARDAR",
                text: "Tem a certeza que deseja guardar a informação?",
                type: 'question',
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

        function checkCustomerOrCar() {
            var text = $('#txtNIF').val();;
            var cust = '1';

            if (text != '' && text != null && text != undefined) {
                $.ajax({
                    type: "POST",
                    url: "index.aspx/checkExistentCarOrCustomer",
                    data: '{"text":"' + text + '","customer":"' + cust + '"}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        if (parseInt(res.d) > 0) {
                            var title = "CLIENTE";
                            var text = 'O cliente com o NIF inserido já existe no sistema!';
                            sweetAlertInfo(title, text);
                        }
                        else {
                            if (cust == '1') {
                                validarnif();
                            }
                        }
                    }
                });
            }
        }

        function validarnif() {
            var nif = $("#txtNIF").val();

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
                            var phone = dados[8];

                            $('#txtName').val(nome);
                            $('#txtAddress').val(morada);
                            $('#txtZipCode').val(codpostal);
                            $('#txtCity').val(localidade);
                            $('#txtEmail').val(email);
                            $('#txtPhone').val(phone);
                            $('#txtNotes').val(notas);
                            $('#txtCountry').val('Portugal');
                        }
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

        function auto_height(elem) {  /* javascript */
            elem.style.height = "1px";
            elem.style.height = (elem.scrollHeight) + "px";
        }
    </script>
</body>

</html>
