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
            
            
            fileInput(inputId = 'fileid', label = "Elija el Archivo Excel"),
            fileInput(inputId = 'fileid2', label = 'Elija el Archivo CSV'),
            fileInput(inputId = 'fileid3', label = 'Elija el Acrivo De Comparacion excel'),
            actionButton(inputId = 'bottomid', label = 'Aceptar')
            
        ),

        mainPanel(
          navbarPage("Tablas",
                     tabPanel("excel", dataTableOutput("fileid")),
                     tabPanel("csv", dataTableOutput('fileid2')),
                     tabPanel("comparador", dataTableOutput('fileid3')),
                     tabPanel("nuevo",verbatimTextOutput("text"))
                     
          ),
            dataTableOutput('nText')
            
        ),
    )
)


server <- function(input, output) {
    load('datas.RData')
    
    output$fileid <- renderDataTable({
        archivo <- read_xlsx(input$fileid$datapath)
        #archivo <- read_xlsx(input$fileid$datapath)
        })
    
    output$fileid2 <- renderDataTable({
        archivo <- read.csv(input$fileid2$datapath)
    })
    
    output$fileid3 <- renderDataTable({
      archivo <- read_xlsx(input$fileid3$datapath)
    })
    
    
    dfc <- eventReactive(input$bottomid, { 
        archivo <- read_xlsx(input$fileid$datapath)
        archivo <- func_limpieza(archivo)
        print(archivo)
    })

    output$nText <- renderDataTable({
        dfc()
    })
    
     tex <- eventReactive(input$bottomid, { 
       print('Utilizamos la función de estandarización para los títulos de la data y los mostramos.')
       print('Llamamos otra data con datos "fiables" de códigos obpp para comparar.')
       print('Estadarizamos el cuerpo de los dataframes de comparación y la data descargada.')
       print('Estandarizamos el cuerpo de los datos de las filas y columnas del dataframe')
       print('Se compara la data descargada de Drive con el comparador, y se le asigna una variable.')
       print('Removemos variables para espacio de memoria.')
       print('Utilizamos una condicional para decir si el codigo está respondido, o no.')
       print('Estandarizamos los saltos de línea, retornos de carro, etc...')
       print('Agrupamos los repondidos y los no respondimos.')
       print('Buscamos en la data patrones para los códigos.')
       print('Mutamos el código de la data.')
       print('Utilizamos datas del proyecto.')
       print('Seleccionamos códigos.')
       print('Mostrar los códigos sin repetirse.')
       print('Flitramos por los Proyectos en Evaluación y limpiamos el código para evitar mostrar códigos repetidos.')
       print('Utilizamos una condicional para comparar códigos.')
       print('Estandarizamos el título de el data de la comparación.')
    })
   
      output$text <- renderPrint({
        tex()
    })
      
    
}

shinyApp(ui = ui, server = server)

