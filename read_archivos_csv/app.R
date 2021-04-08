library(shiny)
library(readxl)
library(lubridate)
library(dplyr)
library(xlsx)

source('funcion_limpieza.R')

ui <- fluidPage(
  
  titlePanel("Lectura de Archivos"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput(inputId = 'fileid', label = "Elija el Archivo de Borrador .Excel"),
      fileInput(inputId = 'fileid2', label = 'Elija el Archivo CSV de los códigos de las OBPP'),
      fileInput(inputId = 'fileid3', label = 'Elija el Archivo Comparación de archivo .Excel'),
      actionButton(inputId = 'bottomid', label = 'Aceptar')
      
    ),
    
    mainPanel(
      
      htmlOutput("titulo"),
      
      navbarPage("Tablas",
                 tabPanel("Tabla Borrador", dataTableOutput("fileid"), htmlOutput('info')),
                 tabPanel("Archivo CSV", dataTableOutput('fileid2'), htmlOutput('info1')),
                 tabPanel("Tabla Comparador", dataTableOutput('fileid3'), htmlOutput('info2')),
                 tabPanel("Cambios Aplicados de Estandarización", htmlOutput("text"), dataTableOutput('nText'))
                 
      )
      
    )
  )
)


server <- function(input, output) {
  
    output$titulo <- renderUI({
      HTML('<h1 style="color: red">Lectura de Archivos</h1>')
    })

    output$fileid <- renderDataTable({
      tryCatch({
       archivo <- read_xlsx(input$fileid$datapath)
      },
      
      error = function(err){
        NULL
      },
      
      finally ={}
      
      )
      
    })
    
    output$fileid2 <- renderDataTable({
      tryCatch({
      archivo <- read.csv(input$fileid2$datapath)
      }, 
      
      error = function(err){
        NULL
      })
    })
    
    output$fileid3 <- renderDataTable({
      tryCatch({
        archivo <- read_xlsx(input$fileid3$datapath)
      }, 
      
      error = function(err){
        NULL
      })
    })
    
    comparadorjuntos <- reactive({
      archivo2 <- read_xlsx(input$fileid3$datapath)
      archivo2 <-  archivo2 %>% 
        mutate(Asunto = trimws(Asunto)) %>% 
        mutate(Asunto = tolower(Asunto)) %>%
        mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
        mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
        mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
        mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))
      print(archivo2)
    })
    
    data <- reactive({
      
      archivo <- read_xlsx(input$fileid$datapath)
      archivo <- func_limpieza(archivo)
      print(archivo)
      cond1 <- archivo$motivo_1 %in% comparadorjuntos$Asunto
      cond2 <- archivo$motivo_2 %in% comparadorjuntos$Asunto | is.na(archivo$motivo_2)
      cond3 <- archivo$motivo_3 %in% comparadorjuntos$Asunto | is.na(archivo$motivo_3)
      cond4 <- archivo$motivo_4 %in% comparadorjuntos$Asunto | is.na(archivo$motivo_4)
      cond5 <- archivo$motivo_5 %in% comparadorjuntos$Asunto | is.na(archivo$motivo_5)
      
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
      resumen_estandar <- archivo %>% filter(respondida == 'No respondida') %>% group_by(estandar) %>% tally(name = 'Proyectos')
    })
    
    comparador <- reactive({
      
      archivo3 <- read_xlsx(input$fileid$datapath)
      
      archivo3 <- func_limpieza(archivo3)
      print(names(archivo3))
      archivo3$codigo_valido <- grepl('^CCO-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}',
                                 archivo3$codigo_de_proyecto) | grepl('^COM-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}',
                                                               archivo3$codigo_de_proyecto)
      
      archivo3 <- archivo3 %>% mutate(clave = paste(codigo_de_proyecto, '-'))
      
      compa <- read.csv(input$fileid2$datapath, stringsAsFactors = F)
      print(compa)
      
      comparador <- compa %>% select(code, obpp_situr_code, obpp_name,state )
      comparador <- unique(comparador$state)
      comparador
      
    })
    
    dfc <- eventReactive(input$bottomid, { 
      
      data <- data()
      comparadorjuntos <- comparadorjuntos()
      comparador <- comparador()

      save(data, comparadorjuntos, comparador, file = './data.RData')
  
    })
    
    output$nText <- renderDataTable({
      dfc()
    })
    
    tex <- eventReactive(input$bottomid, { 
      paste('<p>
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
        </p>')
    })
    
    output$text <- renderUI({
      HTML(tex())
    })
    
    output$info <- renderUI({
      
      tryCatch({
      
      if(is.null(input$fileid)){
        
        texto_html <- paste('<h2>Ingrese el archivo en el buscador de archivos</h2>')
        
        HTML(texto_html)
        
      }
      },
      
      finally = {}
      
      )
      
    })
    
    output$info1 <- renderUI({
      
      tryCatch({
        
        if(is.null(input$fileid)){
          
          texto_html <- paste('<h2>Ingrese el archivo en el buscador de archivos</h2>')
          
          HTML(texto_html)
          
        }
      },
      
      finally = {}
      
      )
      
    })
    
    output$info2 <- renderUI({
      
      tryCatch({
        
        if(is.null(input$fileid)){
          
          texto_html <- paste('<h2>Ingrese el archivo en el buscador de archivos</h2>')
          
          HTML(texto_html)
          
        }
      },
      
      finally = {}
      
      )
      
    })
    
  
}

shinyApp(ui = ui, server = server)