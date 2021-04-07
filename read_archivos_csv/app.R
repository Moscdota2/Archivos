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
                 tabPanel("Archivo CSV", dataTableOutput('fileid2')),
                 tabPanel("Tabla Comparador", dataTableOutput('fileid3')),
                 tabPanel("Cambios Aplicados de Estandarización", verbatimTextOutput("text"), dataTableOutput('nText'))
                 
      ),
      
    )
  )
)


server <- function(input, output) {
  load('datas.RData')
  
  output$titulo <- renderUI({
    HTML('<h1 style="color: red">Lectura de Archivos</h1>')
  })
  
  output$fileid <- renderDataTable({
    archivo <- read_xlsx(input$fileid$datapath)
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
  

  output$info <- renderUI({
    
    texto_html <- paste('<h2 style="background-color: aqua;">Ingrese el archivo en el buscador de archivos</h2>')
    
    HTML(texto_html)
    
  })
  
}

shinyApp(ui = ui, server = server)

