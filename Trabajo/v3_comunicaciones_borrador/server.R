library(shiny)
library(shinydashboard)
library(shinyjs)
library(readxl)
library(dplyr)
library(lubridate)
library(tidyr)
library(DBI)
library(RPostgreSQL)

shinyServer(function(input, output) {

  source('funcion_limpieza.R')
  source('fun_validate_archivos.R')
  source('funcion_alerta.R')
  source('funcion_sql.R')

  output$alcaravan_png <- renderImage({
          list(src = 'WWW/photo_2021-04-12_13-37-57.jpg',
               width = 600)
      })
      
  output$sinco_png <- renderImage({
          list(src = 'WWW/logo_sinco.png',
               width = 600)
        })

  output$titulo <- renderUI({
          HTML('<h1>Inicio</h1>')
      })

  output$file <- renderDT({
      tryCatch({archivo_xlsx(input$fileid$datapath)}, error = function(err){NULL}, finally = {})      
    })

  output$fie <- renderDT({
        tryCatch({funcion_sql()}, error = function(err){NULL},finally ={})
    })

  output$carga_datos <- renderUI({
      fluidPage(
        box(fileInput(inputId = 'fileid', label = "Elija el Archivo de Borrador .Excel", accept = '.xlsx'),
        #fileInput(inputId = 'fileid2', label = 'Elija el Archivo CSV de los códigos de las OBPP', accept = '.csv'),
        width = 6)
        )
      })
    
  output$alerta <- renderUI({
      fluidPage(
        box(fileInput(inputId = 'alerta_arc', label = 'Elija el Archivo CSV', accept = '.csv'),
            width = 6)
      )
    })

  botalertareaccion <- eventReactive(input$botalerta, {
      func_alerta(input$alerta_arc$datapath)
    })
  
  observeEvent(input$botalerta, {
      toggle('alerta2')
    })
    
  output$alerta2 <- renderUI({
    a1 <- input$alerta_arc
    tryCatch({
      if(is.null(a1)){
        HTML('<h1>Cargue Archivo</h1>')
      } else{
        if(is.null(archivo_csv(input$alerta_arc$datapath))){
          HTML('<h1>Cargue Archivo Bien</h1>')
        } else{
          fluidPage(
          splitLayout(
            box(width = 12,
                DTOutput(outputId = 'alertadf')),
            box(width = 12,
                plotOutput(outputId = 'grafica'))
          )
        )
      }
    } 
    }, 
      finally = {})
    })
    
  output$grafica <- renderPlot({
      x <- botalertareaccion()
      hist(x$n, main = 'Histograma de "Casos Atípicos"',
        xlab = 'Proyectos OBPP', ylab = 'Frecuencia')
      #
    })
    
  output$alertadf <- renderDT({
      botalertareaccion()
    })

  output$mostrar_asuntos <- renderUI({
      
      arc_exel <- input$fileid
      #arc_csv <- input$fileid2
      
      tryCatch({
        
        if(is.null(arc_exel)){
          if(exists("data1")){
            arc_exel <- data1
          } else {
            return(HTML('<h1>Cargue Archivo</h1>'))  
          }}
        else {
          if(is.null(archivo_xlsx(arc_exel$datapath))){
            return(HTML('<h1>Cargue Archivo</h1>'))
          } else {
            arc_exel <- archivo_xlsx(arc_exel$datapath)
          }
        }
        
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
    
  observeEvent(input$bot, {
        data1 <- df1()
        comparadorjuntos <- comparadorjuntos1()
        comparador <- comparador1()
        proyectos_en_evaluacion <- proyectos_en_evaluacion1()
        resumen_estandar <- resumen_estandar1()
        resumen_respondida <- resumen_respondida1()
        save(comparador, comparadorjuntos , data1, resumen_estandar,resumen_respondida, proyectos_en_evaluacion, file = './caches.RData')
        toggle('mostrar_asuntos')
        toggle('carga_datos')
    })
    
  df1 <- reactive({

      if(is.null(input$fileid)){
        archivo <- data1
      } else {
        archivo <- read_xlsx(input$fileid$datapath, sheet = "2021")
        archivo <- func_limpieza(archivo)
        archivo <- archivo %>% filter(!is.na(codigo_proyecto))
        archivo2 <- comparadorjuntos2
        archivo2 <- archivo2 %>%
          mutate(Asunto = trimws(Asunto)) %>%
          mutate(Asunto = tolower(Asunto)) %>%
          mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
          mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
          mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
          mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
        cond1 <- archivo$motivo_1 %in% archivo2$Asunto
        cond2 <- archivo$motivo_2 %in% archivo2$Asunto | is.na(archivo$motivo_2)
        cond3 <- archivo$motivo_3 %in% archivo2$Asunto | is.na(archivo$motivo_3)
        cond4 <- archivo$motivo_4 %in% archivo2$Asunto | is.na(archivo$motivo_4)
        cond5 <- archivo$motivo_5 %in% archivo2$Asunto | is.na(archivo$motivo_5)
        estandar <- cond1 & cond2 & cond3 & cond4 & cond5
        archivo$estandar <- estandar
        remove(cond1, cond2, cond3, cond4, cond5, estandar)
        archivo <- archivo %>%
          mutate(respondida = if_else(
            is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
            'No respondida',
            'Respondida'))
        if(is.null(input$fileid)){
          archivo3 <- comparador 
        } else {
          archivo3 <- funcion_sql()
        } 
        proyectos_en_evaluacion <- archivo3 %>% filter(state_proyect %in% 'En evaluación') %>% pull(code)
        archivo <- archivo %>% mutate(codigo_proyecto = gsub('[[:cntrl:]]','',codigo_proyecto)) %>%
          mutate(codigo_proyecto = trimws(codigo_proyecto))
        archivo$codigo_valido <- grepl('^CCO-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}',
                                       archivo$codigo_proyecto) | grepl('^COM-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}',
                                                                        archivo$codigo_proyecto)
        archivo <- archivo %>% mutate(clave = paste(codigo_proyecto, '-',n_))
        archivo <- archivo %>% mutate(estatus_valido = if_else(codigo_proyecto %in% proyectos_en_evaluacion, FALSE,TRUE))
      }
      archivo
    })
    
  comparador1 <- reactive({
      
      if(is.null(input$fileid)){
        archivo3 <- comparador
      } else {
        archivo3 <- funcion_sql()
      }
      archivo3
      
    })
    
  proyectos_en_evaluacion1 <- reactive({
  
      if(is.null(input$fileid)){
        archivo3 <- comparador
      } else {
        archivo3 <- funcion_sql()
      }
      proyectos_en_evaluacion <- archivo3 %>% filter(state_proyect %in% 'En evaluación') %>% pull(code)
      
      proyectos_en_evaluacion
      
    })
    
  resumen_estandar1 <- reactive({
     
      if(is.null(input$fileid)){
        resumen_estandar <- resumen_estandar
      } else {
        archivo <- read_xlsx(input$fileid$datapath, sheet = '2021')
        archivo <-  func_limpieza(archivo)
        archivo <- archivo %>% filter(!is.na(codigo_proyecto))
        archivo2 <- comparadorjuntos2
        archivo2 <- archivo2 %>% 
          mutate(Asunto = trimws(Asunto)) %>% 
          mutate(Asunto = tolower(Asunto)) %>%
          mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
          mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
          mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
          mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
        cond1 <- archivo$motivo_1 %in% archivo2$Asunto
        cond2 <- archivo$motivo_2 %in% archivo2$Asunto | is.na(archivo$motivo_2)
        cond3 <- archivo$motivo_3 %in% archivo2$Asunto | is.na(archivo$motivo_3)
        cond4 <- archivo$motivo_4 %in% archivo2$Asunto | is.na(archivo$motivo_4)
        cond5 <- archivo$motivo_5 %in% archivo2$Asunto | is.na(archivo$motivo_5)
        estandar <- cond1 & cond2 & cond3 & cond4 & cond5
        archivo$estandar <- estandar
        remove(cond1, cond2, cond3, cond4, cond5, estandar)
        archivo <- archivo %>%
          mutate(respondida = if_else(
            is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
            'No respondida',
            'Respondida'))
        archivo <- archivo %>% mutate(codigo_proyecto = gsub('[[:cntrl:]]','',codigo_proyecto)) %>%
          mutate(codigo_proyecto = trimws(codigo_proyecto))
        resumen_estandar <- archivo %>% filter(respondida == 'No respondida') %>% group_by(estandar) %>% tally(name = 'Proyectos')
      }
      
      resumen_estandar
      
    })
    
  resumen_respondida1 <- reactive({

      if(is.null(input$fileid)){
        resumen_respondida <- resumen_respondida
      } else {
        archivo <- read_xlsx(input$fileid$datapath, sheet = '2021')
        archivo <- func_limpieza(archivo)
        archivo <- archivo %>% filter(!is.na(codigo_proyecto))
        archivo2 <- comparadorjuntos2
        archivo2 <- archivo2 %>% 
          mutate(Asunto = trimws(Asunto)) %>% 
          mutate(Asunto = tolower(Asunto)) %>%
          mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
          mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
          mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
          mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
        cond1 <- archivo$motivo_1 %in% archivo2$Asunto
        cond2 <- archivo$motivo_2 %in% archivo2$Asunto | is.na(archivo$motivo_2)
        cond3 <- archivo$motivo_3 %in% archivo2$Asunto | is.na(archivo$motivo_3)
        cond4 <- archivo$motivo_4 %in% archivo2$Asunto | is.na(archivo$motivo_4)
        cond5 <- archivo$motivo_5 %in% archivo2$Asunto | is.na(archivo$motivo_5)
        estandar <- cond1 & cond2 & cond3 & cond4 & cond5
        archivo$estandar <- estandar
        remove(cond1, cond2, cond3, cond4, cond5, estandar)
        archivo <- archivo %>%
          mutate(respondida = if_else(
            is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
            'No respondida',
            'Respondida'))
        archivo <- archivo %>% mutate(codigo_proyecto = gsub('[[:cntrl:]]','',codigo_proyecto)) %>%
          mutate(codigo_proyecto = trimws(codigo_proyecto))
        resumen_respondida <- archivo %>% group_by(respondida) %>% tally(name = 'Proyectos')
      }
      resumen_respondida
    })
    
  comparadorjuntos1 <- reactive({

      archivo2 <- comparadorjuntos2
      archivo2 <- archivo2 %>% mutate(Asuntos_origen = Asunto)
      archivo2 <- archivo2 %>% 
        mutate(Asunto = trimws(Asunto)) %>% 
        mutate(Asunto = tolower(Asunto)) %>%
        mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
        mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
        mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
        mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
      titulo <- func_titulo(archivo2)
      colnames(archivo2) <- titulo
      
      archivo2
      
    })
    
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
   
  output$descarga_no_estandar <- downloadHandler(
      
      filename = function() {
        paste("comunicacionesNoEstandar.csv", sep="")
      },
      content = function(file) {
        data1 <- df1()
        data_descarga <- data1 %>% filter(estandar == FALSE, respondida == 'No respondida', !is.na(codigo_proyecto))
        write.csv(data_descarga, file)
      }
    )
    
  output$descarga_evaluados <- downloadHandler(
      
      filename = function() {
        paste("comunicacionesEvaluadosYA.csv", sep="")
      },
      content = function(file) {
        data1 <- df1()
        comparador <- comparador1()
        codigos <- data1 %>% filter(respondida == 'No respondida') %>% pull(codigo_proyecto)
        data_descarga <- comparador %>% filter(code %in% codigos, state_proyect == 'En evaluación')
        write.csv(data_descarga, file)
      }
    )
    
  output$estatus <- renderUI({
      resumen_respondida <- resumen_respondida1()
        HTML(paste('<b>No Respondidas</b>:',
                   as.numeric(resumen_respondida[resumen_respondida$respondida == 'No respondida', 'Proyectos']),
                   '</br>','<b>Respondidas</b>:',
                   as.numeric(resumen_respondida[resumen_respondida$respondida == 'Respondida', 'Proyectos'])))
    })
    
  output$estandar <- renderUI({
      resumen_estandar <- resumen_estandar1()
        HTML(paste('<b>No estandar</b>:',
                   as.numeric(resumen_estandar[resumen_estandar$estandar == FALSE, 'Proyectos']),
                   '</br>','<b>Estandar</b>:',
                   as.numeric(resumen_estandar[resumen_estandar$estandar == TRUE, 'Proyectos'])))
    })
       
  output$estatus_proyecto <- renderUI({
      data1 <- df1()
      comparador <- comparador1()
        data_aux <- data1 %>% filter(respondida != 'Respondida') %>% pull(codigo_proyecto)
        data_aux <- data_aux[!is.na(data_aux)]
        resumen_estatus <- comparador %>% filter(code %in% data_aux) %>% group_by(state_proyect) %>% tally()
        HTML(paste('<b>No Borrador</b>:',
                   resumen_estatus[resumen_estatus$state_proyect == 'Borrador', 'n'],'</br>',
                   '<b>En Evaluacion</b>:',
                   resumen_estatus[resumen_estatus$state_proyect == 'En evaluación', 'n'],'</br>',
                   '<b>En Preevaluacion</b>:',
                   resumen_estatus[resumen_estatus$state_proyect == 'Pre-evaluación', 'n']
        ))
    })
       
  output$titulo2 <- renderUI({
        HTML('<h1 style="color: blue">RESPUESTAS PARA “ESTATUS BORRADOR”.</h1>')
    })
    
  output$comunicacion2 <- renderUI({
      
      data1 <- df1()
      comparador <- comparador1()
      comparadorjuntos <- comparadorjuntos1()
        data_aux <- data1 %>% filter(clave == input$in3, respondida == 'No respondida')
        nombre_obpp <- comparador %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(obpp_name)
        nombre_codigo <- comparador %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(obpp_situr_name)
        estatus_proyecto <- comparador %>% filter(code %in% data_aux$codigo_proyecto) %>% pull(state_proyect)
        data1 <- data1 %>% filter(clave == input$in3, estandar, codigo_valido, respondida == 'No respondida')
        motivo_1 <- comparadorjuntos %>% filter(asunto == data1$motivo_1) %>% pull(asuntos_origen)
        motivo_2 <- comparadorjuntos %>% filter(asunto == data1$motivo_2) %>% pull(asuntos_origen)
        motivo_3 <- comparadorjuntos %>% filter(asunto == data1$motivo_3) %>% pull(asuntos_origen)
        motivo_4 <- comparadorjuntos %>% filter(asunto == data1$motivo_4) %>% pull(asuntos_origen)
        motivo_5 <- comparadorjuntos %>% filter(asunto == data1$motivo_5) %>% pull(asuntos_origen)
        informacion_1 <- comparadorjuntos %>% filter(asunto == data1$motivo_1) %>% pull(informacion)
        informacion_2 <- comparadorjuntos %>% filter(asunto == data1$motivo_2) %>% pull(informacion)
        informacion_3 <- comparadorjuntos %>% filter(asunto == data1$motivo_3) %>% pull(informacion)
        informacion_4 <- comparadorjuntos %>% filter(asunto == data1$motivo_4) %>% pull(informacion)
        informacion_5 <- comparadorjuntos %>% filter(asunto == data1$motivo_5) %>% pull(informacion)
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
        data1 <- df1()
        opciones <- data1 %>% filter(respondida == 'No respondida',
                                    codigo_valido == TRUE, estatus_valido == TRUE, estandar == TRUE) %>%  pull(clave)
        selectInput('in3', '', opciones , multiple=TRUE, selectize=FALSE, selected = opciones[1] )
    })
})