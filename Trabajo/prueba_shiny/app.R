library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Devolución a Borrador"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            
            HTML('<h3>Estatus de Respuesta</h3>'),
            htmlOutput('estatus'),
        
            
            HTML('<h3>Tipo de NO Respondidas</h3>'),
            htmlOutput('estandar'),
            
            HTML('<h3>Evaluados</h3>'),
            selectInput('inevaluados', '', data %>%
                            filter(respondida == 'No respondida', codigo_valido == TRUE, estatus_valido == FALSE) %>%
                            pull(clave), multiple=TRUE, selectize=FALSE ),
            
            
            HTML('<h3>Respuestas estandar</h3>'),
            selectInput('in3', 'Options', data %>%
                            filter(respondida == 'No respondida', codigo_valido == TRUE, estatus_valido == TRUE, estandar == TRUE) %>%
                            pull(clave), multiple=TRUE, selectize=FALSE )
            
            
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            htmlOutput("titulo"),
            htmlOutput("comunicacion")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$estatus <- renderUI({
        HTML(paste('<b>No Respondidas</b>:',
                   as.numeric(resumen_respondida[resumen_respondida$respondida == 'No respondida', 'Proyectos']),
                   '</br>','<b>Respondidas</b>:',
                   as.numeric(resumen_respondida[resumen_respondida$respondida == 'Respondida', 'Proyectos'])))
    })
    
    output$estandar <- renderUI({
        HTML(paste('<b>No No estandar</b>:',
                   as.numeric(resumen_estandar[resumen_estandar$estandar == FALSE, 'Proyectos']),
                   '</br>','<b>Estandar</b>:',
                   as.numeric(resumen_estandar[resumen_estandar$estandar == TRUE, 'Proyectos'])))
    })
    
    
    
    output$titulo <- renderUI({
        

        HTML('<h1 style="color: red">TEXTO MODELO, RESPUESTAS PARA “ESTATUS BORRADOR”.</h1>')
    })
    
    output$comunicacion <- renderUI({
        
        print(input$in3)
        
        data_aux <- data %>% filter(clave == input$in3, respondida == 'No respondida')
        print(data_aux$codigo_proyecto)
        
        nombre_obpp <- comparadol %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(obpp_name)
        nombre_codigo <- comparadol %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(obpp_situr_code)
        estatus_proyecto <- comparadol %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(state)
        
        motivo_1 <- data %>% filter(clave == input$in3, estandar, codigo_valido, respondida == 'No respondida') %>% pull(motivo_1)
        motivo_2 <- data %>% filter(clave == input$in3, estandar, codigo_valido, respondida == 'No respondida') %>% pull(motivo_2)
        motivo_3 <- data %>% filter(clave == input$in3, estandar, codigo_valido, respondida == 'No respondida') %>% pull(motivo_3)
        motivo_4 <- data %>% filter(clave == input$in3, estandar, codigo_valido, respondida == 'No respondida') %>% pull(motivo_4)
        motivo_5 <- data %>% filter(clave == input$in3, estandar, codigo_valido, respondida == 'No respondida') %>% pull(motivo_5)
        
        if(is.na(motivo_2))
            motivo_2 <- ''
        if(is.na(motivo_3))
            motivo_3 <- ''
        if(is.na(motivo_4))
            motivo_4 <- ''
        if(is.na(motivo_5))
            motivo_5 <- ''
        
        informacion_1 <- comparadorjuntos %>% filter(asunto == motivo_1) %>% pull(informacion)
        informacion_2 <- comparadorjuntos %>% filter(asunto == motivo_2) %>% pull(informacion)
        informacion_3 <- comparadorjuntos %>% filter(asunto == motivo_3) %>% pull(informacion)
        informacion_4 <- comparadorjuntos %>% filter(asunto == motivo_4) %>% pull(informacion)
        informacion_5 <- comparadorjuntos %>% filter(asunto == motivo_5) %>% pull(informacion)
        
        # (leopoldo): lo comento por si lo necesito (aunque no creo porque no dejamos NA en la data de la comparación!)
        #if(is.na(informacion_2))
        #informacion_2 <- ''
        #if(is.na(informacion_3))
        #  informacion_3 <- ''
        #if(is.na(informacion_4))
        #  informacion_4 <- ''
        #if(is.na(informacion_5))
        #  informacion_5 <- ''
        
        texto_html <- paste('<p>
			<b><i>Título de las comunicaciones:</i></b><br><br>

			Indicaciones para corregir proyecto en estatus borrador –' ,nombre_obpp, 'y' ,nombre_codigo, '.<br>
			<hr> <br>
			
			<i><b><b1>Texto de las comunicaciones:</b1></b></i><br><br>

			<i>Estimados voceros y voceras del Poder Popular ante todo reciban un cordial saludo.</i><br><br>

			Por medio de la presente, y posterior a la revisión y evaluación realizada al proyecto cargado en SINCO para su financiamiento, cumplimos con informarle que el proyecto se encuentra en
			 <b>“Estatus Borrador”</b>, por la(s) siguiente(s) razón(es):<br><br>

			<u><i><b>',motivo_1,'</b></i></u><p>',informacion_1,'</p><br>
			<u><i><b>',motivo_2,'</b></i></u><p>',informacion_2,'</p><br>
			<u><i><b>',motivo_3,'</b></i></u><p>',informacion_3,'</p><br>
			<u><i><b>',motivo_4,'</b></i></u><p>',informacion_4,'</p><br>
			<u><i><b>',motivo_5,'</b></i></u><p>',informacion_5,'</p><br>


			Una vez realizada las correcciones correspondientes, haga clic nuevamente en el botón finalizar del paso 5 para que su proyecto sea evaluado nuevamente.
			Recuerde que en caso de presentar inconvenientes puede enviar una comunicación a través del módulo del sistema.<br><br>

			<b>EN SINCO, Creamos condiciones para el beneficio colectivo.</b><hr>
			
			<h1>',estatus_proyecto,'</h1>

		</p>')
        
        
        HTML(texto_html)
    })
    
}

shinyApp(ui = ui, server = server)
