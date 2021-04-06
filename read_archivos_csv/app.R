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
            actionButton(inputId = 'bottomid', label = 'Aceptar')
            
        ),

        mainPanel(
            dataTableOutput("fileid"),
            dataTableOutput('fileid2'),
            dataTableOutput('nText')
            
        ),
    )
)


server <- function(input, output) {
    
    output$fileid <- renderDataTable({
        archivo <- read_xlsx(input$fileid$datapath)
        #archivo <- read_xlsx(input$fileid$datapath)
        })
    
    output$fileid2 <- renderDataTable({
        archivo <- read.csv(input$fileid2$datapath)
    })
    
    dfc <- eventReactive(input$bottomid, { 
        archivo <- read_xlsx(input$fileid$datapath)
        archivo <- func_limpieza(archivo)
        print(archivo)
    })

    output$nText <- renderDataTable({
        dfc()
    })
    

}

shinyApp(ui = ui, server = server)