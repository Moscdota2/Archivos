library(shiny)
library(shinydashboard)
library(readxl)

shinyServer(function(input, output) {

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
        grt <- read_xlsx(input$fileid$datapath, sheet = '2021')
        head(grt)
        })
    output$fie <- renderDataTable({
        tet <- read.csv(input$fileid2$datapath, stringsAsFactors = F)
        head(tet)
    })
   
    ##############################################################################
    
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
    
    data <- reactive({
        
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
        
        
        # CArgar el archivo 2 y filtrado por evaluacion -- comparador.csv
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
        
        # CArgar el archivo 2 y filtrado por evaluacion -- comparador.csv
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
    
    ##############################################################################
    
    dfc <- eventReactive(input$bot, { 
        
        data <- data()
        
        comparadorjuntos <- comparadorjuntos()
        
        comparador <- comparador()
        
        proyectos_en_evaluacion <- proyectos_en_evaluacion()
        
        resumen_estandar <- resumen_estandar()
        
        resumen_respondida <- resumen_respondida()
        
        
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
    
})
