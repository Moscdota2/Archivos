#server
library(shiny)
library(dplyr)


server <- function(input, output) {
  load('./datas.RData')
  
  
  
  #Colocamos un link para que los analistas puedan descargar los datos que no se pueden responder automatizadamente.  
  output$descarga_no_estandar <- downloadHandler(
    
    filename = function() {
      paste("comunicacionesNoEstandar.csv", sep="")
    },
    content = function(file) {
      
      data_descarga <- data %>% filter(estandar == FALSE, respondida == 'No respondida', !is.na(codigo_proyecto))
      
      write.csv(data_descarga, file)
    }
  )
  
  
  output$descarga_evaluados <- downloadHandler(
    
    filename = function() {
      paste("comunicacionesEvaluadosYA.csv", sep="")
    },
    content = function(file) {
      codigos <- data %>% filter(respondida == 'No respondida') %>% pull(codigo_proyecto)
      
      data_descarga <- comparador %>% filter(code %in% codigos, state == 'En evaluación')
      write.csv(data_descarga, file)
    }
  )
  
  #Mostramos los no respondidos y respondidos.  
  output$estatus <- renderUI({
    HTML(paste('<b>No Respondidas</b>:',
               as.numeric(resumen_respondida[resumen_respondida$respondida == 'No respondida', 'Proyectos']),
               '</br>','<b>Respondidas</b>:',
               as.numeric(resumen_respondida[resumen_respondida$respondida == 'Respondida', 'Proyectos'])))
  })
  
  #Moestramos los estandarizados.    
  output$estandar <- renderUI({
    HTML(paste('<b>No estandar</b>:',
               as.numeric(resumen_estandar[resumen_estandar$estandar == FALSE, 'Proyectos']),
               '</br>','<b>Estandar</b>:',
               as.numeric(resumen_estandar[resumen_estandar$estandar == TRUE, 'Proyectos'])))
  })
  
  #Mostramos por pantalla la cantidad de proyectos con sus diferentes estatus.       
  output$estatus_proyecto <- renderUI({
    
    data_aux <- data %>% filter(respondida != 'Respondida') %>% pull(codigo_proyecto)
    data_aux <- data_aux[!is.na(data_aux)]
    
    resumen_estatus <- comparador %>% filter(code %in% data_aux) %>% group_by(state) %>% tally()
    
    HTML(paste('<b>No Borrador</b>:',
               resumen_estatus[resumen_estatus$state == 'Borrador', 'n'],'</br>',
               '<b>En Evaluacion</b>:',
               resumen_estatus[resumen_estatus$state == 'En evaluación', 'n'],'</br>',
               '<b>En Preevaluacion</b>:',
               resumen_estatus[resumen_estatus$state == 'Pre-evaluación', 'n']
    ))
  })
  
  #Empezamos con el encabezado HTML para la presentación.        
  output$titulo <- renderUI({
    HTML('<h1 style="color: red">TEXTO MODELO, RESPUESTAS PARA “ESTATUS BORRADOR”.</h1>')
  })
  
  #Mostramos la comunicación de SINCO, utilizamos nuestras variables para mostrar los motivos correspondientes de cada proyecto.       
  output$comunicacion <- renderUI({
    
    data_aux <- data %>% filter(clave == input$in3, respondida == 'No respondida')
    
    nombre_obpp <- comparador %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(obpp_name)
    nombre_codigo <- comparador %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(obpp_situr_code)
    estatus_proyecto <- comparador %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(state)
    
    data <- data %>% filter(clave == input$in3, estandar, codigo_valido, respondida == 'No respondida')
    
    motivo_1 <- comparadorjuntos %>% filter(asunto == data$motivo_1) %>% pull(asuntos_origen)
    motivo_2 <- comparadorjuntos %>% filter(asunto == data$motivo_2) %>% pull(asuntos_origen)
    motivo_3 <- comparadorjuntos %>% filter(asunto == data$motivo_3) %>% pull(asuntos_origen)
    motivo_4 <- comparadorjuntos %>% filter(asunto == data$motivo_4) %>% pull(asuntos_origen)
    motivo_5 <- comparadorjuntos %>% filter(asunto == data$motivo_5) %>% pull(asuntos_origen)
    
    #if(is.na(motivo_2))
    #  motivo_2 <- ''
    #if(is.na(motivo_3))
    #  motivo_3 <- ''
    #if(is.na(motivo_4))
    #  motivo_4 <- ''
    #if(is.na(motivo_5))
    #  motivo_5 <- ''
    
    informacion_1 <- comparadorjuntos %>% filter(asunto == data$motivo_1) %>% pull(informacion)
    informacion_2 <- comparadorjuntos %>% filter(asunto == data$motivo_2) %>% pull(informacion)
    informacion_3 <- comparadorjuntos %>% filter(asunto == data$motivo_3) %>% pull(informacion)
    informacion_4 <- comparadorjuntos %>% filter(asunto == data$motivo_4) %>% pull(informacion)
    informacion_5 <- comparadorjuntos %>% filter(asunto == data$motivo_5) %>% pull(informacion)
    
    texto_html <- paste('<p>
			<b><i>Título de las comunicaciones:</i></b><br><br>
			Indicaciones para corregir proyecto en estatus borrador –' ,nombre_obpp, '(' ,nombre_codigo, ').<br>
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
			<hr>
			<b>Estatus del proyecto:</b><p>',estatus_proyecto,'</p></h1>
		</p>')
    
    
    HTML(texto_html)
  })
  
  output$respuestas_estandar <- renderUI({
    
    opciones <- data %>% filter(respondida == 'No respondida', codigo_valido == TRUE, estatus_valido == TRUE, estandar == TRUE) %>%  pull(clave)
    
    selectInput('in3', '', opciones , multiple=TRUE, selectize=FALSE, selected = opciones[1] )
    
    
  })
}