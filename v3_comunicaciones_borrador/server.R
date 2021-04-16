library(shiny)
library(shinydashboard)
library(shinyjs)
library(readxl)
library(dplyr)


source('funcion_limpieza.R')
source('fun_validate_archivos.R')

shinyServer(function(input, output) {
  
    ####### Pagina 1#######
      #Vista de imagen Leo
      output$alcaravan_png <- renderImage({
          list(src = 'WWW/photo_2021-04-12_13-37-57.jpg',
               width = 600)
      })
      
      #Vista de imagen Leo
      output$sinco_png <- renderImage({
          list(src = 'WWW/logo_sinco.png',
               width = 600)
      })
      
      #Vista de HTML Inicio Leo
      output$titulo <- renderUI({
          HTML('<h1>Inicio</h1>')
      })
    
    ##############################################################################
    output$file <- renderDataTable({
        
      tryCatch({
          lol <- input$fileid$datapath
          print(archivo_xlsx(lol))
          
          },
        
        error = function(err){
             NULL
        },
        
        finally ={}
      )
    })

    output$fie <- renderDataTable({
        
        tryCatch({
            nub <- input$fileid2$datapath
            print(archivo_csv(nub))
        
        },
        
        error = function(err){
            NULL
        },
        
        finally ={}
        
        )
    })
   
    ##############################################################################
    
    output$carga_datos <- renderUI({
      fluidPage(
        box(fileInput(inputId = 'fileid', label = "Elija el Archivo de Borrador .Excel", accept = '.xlsx'),
        fileInput(inputId = 'fileid2', label = 'Elija el Archivo CSV de los códigos de las OBPP', accept = '.csv'),
        width = 6)
        )
      })
    
    output$mostrar_asuntos <- renderUI({
      
      tryCatch({
          arc_exel <- input$fileid
          arc_csv <- input$fileid2
        
        
        if(is.null(arc_exel)){
          return(HTML('<h1>Cargue Archivo</h1>'))}
        
        if(is.null(arc_csv)){
          return(HTML('<h1>Cargue Archivo</h1>'))}
          
        if(is.null(archivo_xlsx(arc_exel$datapath))){
          return(HTML('<h1>Cargue Archivo</h1>'))
        }
        
        if(is.null(archivo_csv(arc_csv$datapath))){
          return(HTML('<h1>Cargue Archivo</h1>'))
        }
      s
                
        
        
        fluidPage(box(
          box(
            HTML('<h3>Estatus de Respuesta</h3>'),
            htmlOutput('estatus'),
            HTML('<h3>Tipo de NO Respondidas</h3>'),
            htmlOutput('estandar'),
            downloadLink("descarga_no_estandar", "Descargar proyectos con comunicaciones no estandar"),
            HTML('<h3>Evaluados</h3>'),
            htmlOutput('estatus_proyecto'),
            downloadLink("descarga_evaluados", "Descargar proyectos ya evaluados"),
            HTML('<h3>Respuestas estandar</h3>'),
            htmlOutput(("respuestas_estandar")), width = 4
          ),
          
          
        
          box(
            htmlOutput("titulo2"), 
            htmlOutput("comunicacion2"), width = 8),
          
          width = 12))
        
        
      },error = function(err){return(HTML('<h1>Error</h1>'))}, finally = {})
      
      
      
    })

    #############################################################################
    #

    ##############################################################################
    
    
    observeEvent(input$bot, {
      toggle('mostrar_asuntos')
      toggle('carga_datos')
    })
    
  
    
    df <- reactive({

      # CArgar archivo 1
      archivo <- read_xlsx(input$fileid$datapath, sheet = "2021")
      archivo <- func_limpieza(archivo)
      archivo <- archivo %>% filter(!is.na(codigo_proyecto))
      ####

      # # Cargar el archivo 3 -- Comparadorjuntos
      archivo2 <- comparadorjuntos2



      archivo2 <- archivo2 %>%
        mutate(Asunto = trimws(Asunto)) %>%
        mutate(Asunto = tolower(Asunto)) %>%
        mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
        mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
        mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
        mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
      ####


      # Comparacion de los asuntos
      cond1 <- archivo$motivo_1 %in% archivo2$Asunto
      cond2 <- archivo$motivo_2 %in% archivo2$Asunto | is.na(archivo$motivo_2)
      cond3 <- archivo$motivo_3 %in% archivo2$Asunto | is.na(archivo$motivo_3)
      cond4 <- archivo$motivo_4 %in% archivo2$Asunto | is.na(archivo$motivo_4)
      cond5 <- archivo$motivo_5 %in% archivo2$Asunto | is.na(archivo$motivo_5)

      estandar <- cond1 & cond2 & cond3 & cond4 & cond5

      archivo$estandar <- estandar

      remove(cond1, cond2, cond3, cond4, cond5, estandar)
      ####

      # Filtrar los no respondidos o respondidos
      archivo <- archivo %>%
        mutate(respondida = if_else(
          is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
          'No respondida',
          'Respondida'))
      ####


      # Cargar el archivo 2 y filtrado por evaluacion -- comparador.csv
      archivo3 <- read.csv(input$fileid2$datapath, stringsAsFactors = FALSE)

      archivo3 <- archivo3 %>% select(code, obpp_situr_code, obpp_name,state )

      proyectos_en_evaluacion <- archivo3 %>% filter(state %in% 'En evaluación') %>% pull(code)
      ####

      archivo <- archivo %>% mutate(codigo_proyecto = gsub('[[:cntrl:]]','',codigo_proyecto)) %>%
        mutate(codigo_proyecto = trimws(codigo_proyecto))

      archivo$codigo_valido <- grepl('^CCO-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}',
                                     archivo$codigo_proyecto) | grepl('^COM-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}',
                                                                      archivo$codigo_proyecto)

      archivo <- archivo %>% mutate(clave = paste(codigo_proyecto, '-',n_))

      archivo <- archivo %>% mutate(estatus_valido = if_else(codigo_proyecto %in% proyectos_en_evaluacion, FALSE,TRUE))
      
      # Devolver el dato
      archivo

    })
    
    comparador <- reactive({
      
      # Cargar el archivo 2 y filtrado por evaluacion -- comparador.csv
      archivo3 <- read.csv(input$fileid2$datapath, stringsAsFactors = FALSE)
      
      archivo3 <- archivo3 %>% select(code, obpp_situr_code, obpp_name,state )
      ####
      
      # Devolver el dato
      archivo3
      
    })
    
    proyectos_en_evaluacion <- reactive({
      
      # CArgar el archivo 2 y filtrado por evaluacion -- comparador.csv
      archivo3 <- read.csv(input$fileid2$datapath, stringsAsFactors = FALSE)
      
      archivo3 <- archivo3 %>% select(code, obpp_situr_code, obpp_name,state )
      
      
      proyectos_en_evaluacion <- archivo3 %>% filter(state %in% 'En evaluación') %>% pull(code)
      proyectos_en_evaluacion
      
      
    })
    
    resumen_estandar <- reactive({
      
      
      # CArgar archivo 1
      archivo <- read_xlsx(input$fileid$datapath, sheet = '2021')
      archivo <-  func_limpieza(archivo)
      
      archivo <- archivo %>% filter(!is.na(codigo_proyecto))
      #### 
      
      # Cargar el archivo 3 -- Comparadorjuntos
      archivo2 <- comparadorjuntos2
      
      
      
      archivo2 <- archivo2 %>% 
        mutate(Asunto = trimws(Asunto)) %>% 
        mutate(Asunto = tolower(Asunto)) %>%
        mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
        mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
        mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
        mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
      ####
      
      
      # Comparacion de los asuntos
      cond1 <- archivo$motivo_1 %in% archivo2$Asunto
      cond2 <- archivo$motivo_2 %in% archivo2$Asunto | is.na(archivo$motivo_2)
      cond3 <- archivo$motivo_3 %in% archivo2$Asunto | is.na(archivo$motivo_3)
      cond4 <- archivo$motivo_4 %in% archivo2$Asunto | is.na(archivo$motivo_4)
      cond5 <- archivo$motivo_5 %in% archivo2$Asunto | is.na(archivo$motivo_5)
      
      estandar <- cond1 & cond2 & cond3 & cond4 & cond5
      
      archivo$estandar <- estandar
      
      remove(cond1, cond2, cond3, cond4, cond5, estandar)
      ####
      
      # Filtrar los no respondidos o respondidos
      archivo <- archivo %>%
        mutate(respondida = if_else(
          is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
          'No respondida',
          'Respondida'))
      #### 
      
      
      archivo <- archivo %>% mutate(codigo_proyecto = gsub('[[:cntrl:]]','',codigo_proyecto)) %>%
        mutate(codigo_proyecto = trimws(codigo_proyecto))
      
      resumen_estandar <- archivo %>% filter(respondida == 'No respondida') %>% group_by(estandar) %>% tally(name = 'Proyectos')
      
      # Devolver el dato
      resumen_estandar
      
    })
    
    resumen_respondida <- reactive({
      
      # CArgar archivo 1
      archivo <- read_xlsx(input$fileid$datapath, sheet = '2021')
      archivo <-  func_limpieza(archivo)
      
      archivo <- archivo %>% filter(!is.na(codigo_proyecto))
      #### 
      
      # Cargar el archivo 3 -- Comparadorjuntos
      archivo2 <- comparadorjuntos2
      
      
      
      archivo2 <- archivo2 %>% 
        mutate(Asunto = trimws(Asunto)) %>% 
        mutate(Asunto = tolower(Asunto)) %>%
        mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
        mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
        mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
        mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
      ####
      
      # Comparacion de los asuntos
      cond1 <- archivo$motivo_1 %in% archivo2$Asunto
      cond2 <- archivo$motivo_2 %in% archivo2$Asunto | is.na(archivo$motivo_2)
      cond3 <- archivo$motivo_3 %in% archivo2$Asunto | is.na(archivo$motivo_3)
      cond4 <- archivo$motivo_4 %in% archivo2$Asunto | is.na(archivo$motivo_4)
      cond5 <- archivo$motivo_5 %in% archivo2$Asunto | is.na(archivo$motivo_5)
      
      estandar <- cond1 & cond2 & cond3 & cond4 & cond5
      
      archivo$estandar <- estandar
      
      remove(cond1, cond2, cond3, cond4, cond5, estandar)
      ####
      
      # Filtrar los no respondidos o respondidos
      archivo <- archivo %>%
        mutate(respondida = if_else(
          is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
          'No respondida',
          'Respondida'))
      #### 
      
      
      archivo <- archivo %>% mutate(codigo_proyecto = gsub('[[:cntrl:]]','',codigo_proyecto)) %>%
        mutate(codigo_proyecto = trimws(codigo_proyecto))
      
      resumen_respondida <- archivo %>% group_by(respondida) %>% tally(name = 'Proyectos')
      
      # Devolver el dato
      resumen_respondida
      
    })
    
    comparadorjuntos <- reactive({
      
      # Cargar el archivo 3 -- Comparadorjuntos
      archivo2 <- comparadorjuntos2
      
      archivo2 <- archivo2 %>% mutate(Asuntos_origen = Asunto)
      
      archivo2 <- archivo2 %>% 
        mutate(Asunto = trimws(Asunto)) %>% 
        mutate(Asunto = tolower(Asunto)) %>%
        mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
        mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
        mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
        mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
      ####
      
      titulo <- func_titulo(archivo2)
      colnames(archivo2) <- titulo
      
      # Devolver el dato
      archivo2
    })
    
    ###############################################################################    
    #Vista HTML Pasos Leo
    output$texto <- renderUI({
        box(HTML('<p>
            1-Utilizamos la función de estandarización para los títulos de la data y los mostramos.<br>
            2-Llamamos otra data con datos "fiables" de códigos <b>OBPP</b> para comparar.<br>
            3-Estadarizamos el cuerpo de los dataframes de comparación y la data descargada.<br>
            4-Estandarizamos el cuerpo de los datos de las filas y columnas del dataframe<br>
            5-Se compara la data descargada de Drive con el comparador, y se le asigna una variable.<br>
            6-Removemos variables para espacio de memoria.<br>
            7-Utilizamos una condicional para decir si el codigo está respondido, o no.<br>
            8-Estandarizamos los saltos de línea, retornos de carro, etc...<br>
            9-Agrupamos los repondidos y los no respondidos.<br>
            10-Buscamos en la data patrones para los códigos.<br>
            11-Mutamos el código de la data.<br>
            12-Utilizamos las datas del proyecto.<br>
            13-Seleccionamos códigos.<br>
            14-Mostrar los códigos sin repetirse.<br>
            15-Flitramos por los Proyectos en Evaluación y limpiamos el código para evitar mostrar códigos repetidos.<br>
            16-Utilizamos una condicional para comparar códigos.<br>
            17-Estandarizamos el título de la data de la comparación.<br>
        </p>'))
    })
   
  
    #Colocamos un link para que los analistas puedan descargar los datos que no se pueden responder automatizadamente.  
   
    output$descarga_no_estandar <- downloadHandler(
      
      filename = function() {
        paste("comunicacionesNoEstandar.csv", sep="")
      },
      content = function(file) {
        data <- df()
        data_descarga <- data %>% filter(estandar == FALSE, respondida == 'No respondida', !is.na(codigo_proyecto))
        
        write.csv(data_descarga, file)
      }
    )
    
    
    output$descarga_evaluados <- downloadHandler(
      filename = function() {
        paste("comunicacionesEvaluadosYA.csv", sep="")
      },
      content = function(file) {
        data <- df()
        comparador <- comparador()
        
        codigos <- data %>% filter(respondida == 'No respondida') %>% pull(codigo_proyecto)
        
        data_descarga <- comparador %>% filter(code %in% codigos, state == 'En evaluación')
        write.csv(data_descarga, file)
      }
    )
    
    #Mostramos los no respondidos y respondidos.  
    output$estatus <- renderUI({
      resumen_respondida <- resumen_respondida()
        HTML(paste('<b>No Respondidas</b>:',
                   as.numeric(resumen_respondida[resumen_respondida$respondida == 'No respondida', 'Proyectos']),
                   '</br>','<b>Respondidas</b>:',
                   as.numeric(resumen_respondida[resumen_respondida$respondida == 'Respondida', 'Proyectos'])))
    })
    
    #Moestramos los estandarizados.    
    output$estandar <- renderUI({
      resumen_estandar <- resumen_estandar()
        HTML(paste('<b>No estandar</b>:',
                   as.numeric(resumen_estandar[resumen_estandar$estandar == FALSE, 'Proyectos']),
                   '</br>','<b>Estandar</b>:',
                   as.numeric(resumen_estandar[resumen_estandar$estandar == TRUE, 'Proyectos'])))
    })
    
    #Mostramos por pantalla la cantidad de proyectos con sus diferentes estatus.       
    output$estatus_proyecto <- renderUI({
      data <- df()
      comparador <- comparador()
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
    output$titulo2 <- renderUI({
        HTML('<h1 style="color: blue">RESPUESTAS PARA “ESTATUS BORRADOR”.</h1>')
    })
    
    #Mostramos la comunicación de SINCO, utilizamos nuestras variables para mostrar los motivos correspondientes de cada proyecto.       
    output$comunicacion2 <- renderUI({
      
      data <- df()
      comparador <- comparador()
      comparadorjuntos <- comparadorjuntos()
      
      
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
			<b>EN SINCO, Creamos condiciones para el beneficio colectivo.</b>
			<hr>
			<b>Estatus del proyecto:</b><p>',estatus_proyecto,'</p></h1>
		</p>')
        
        
        HTML(texto_html)
    })
    
    output$respuestas_estandar <- renderUI({
        data <- df()
        opciones <- data %>% filter(respondida == 'No respondida', codigo_valido == TRUE, estatus_valido == TRUE, estandar == TRUE) %>%  pull(clave)
        
        selectInput('in3', '', opciones , multiple=TRUE, selectize=FALSE, selected = opciones[1] )
        
        
    })
    
    
})
