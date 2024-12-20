<%@ Application Language="C#" %>

<script runat="server">

    void Application_Start(object sender, EventArgs e)
    {
        // Inicia a fila de processamento do status das maquinas
        //filaBackground.StatusWorker_FilaStatusMaquinasStart();

        //// Inicia a fila de obter os movimentos das máquinas
        //filaBackground.StatusWorker_FilaMovimentosMaquinaStart();

        //// Inicia a fila de obter os niveis em falta das maquinas ligadas
        //filaBackground.StatusWorker_FilaEstadoFundoMaquinaStart();

        ////Inicia a fila de enviar os emails diários acerca das manutençoes que terão de ser efetuadas dentro de 2 semanas
        //filaBackground.StatusWorker_FilaEnvioEmailManutencaoStart();

        ////Inicia a fila de enviar os emails de alterações de serials nas máquinas
        //filaBackground.StatusWorker_FilaEnvioEmailsAlteracaoSerialsMaquinasStart();
    }

    void Application_End(object sender, EventArgs e)
    {
        //  Code that runs on application shutdown

    }

    void Application_Error(object sender, EventArgs e)
    {
        // Code that runs when an unhandled error occurs

    }

    void Session_Start(object sender, EventArgs e)
    {
        // Code that runs when a new session is started

    }

    void Session_End(object sender, EventArgs e)
    {
        // Code that runs when a session ends. 
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.

    }

</script>
