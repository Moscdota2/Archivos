library(shiny)
library(shinydashboard)
library(readxl)
library(dplyr)
library(shinyjs)
    
 ui <- fluidPage(#Leo
   useShinyjs(),
  dashboardPage( skin = 'black',
       dashboardHeader(title = "Devolución a Borrador"),
      dashboardSidebar(
        width = 260,
      sidebarMenu(
        menuItem("Inicio", tabName = "inicio", icon = icon("home")),
        menuItem("Información", tabName = "info", icon = icon("envelope")),
        menuItem("Data Borrador", tabName = "borrador",icon = icon("folder-open")),
        menuItem("Data Códigos SINCO", tabName = "code_sinco", icon = icon("folder-open")),
        menuItem("Acciones hechas por el programa", tabName = 'pasos', icon = icon("info"))
                           ) 
                       ),
                       dashboardBody(
                           tabItems(
                               tabItem(
                                   tabName = 'inicio',
                                   box(solidHeader = T, 
                                       width = 12, column(12, align="center", imageOutput('alcaravan_png',height = "200px"))),
                                   box(solidHeader = F, 
                                       width = 12, column(12, align="center", imageOutput('sinco_png', height = "375px")))
                               ),
                               tabItem(
                                   tabName = 'info',
                                   box(
                                     fileInput(inputId = 'fileid', label = "Elija el Archivo de Borrador .Excel"),
                                       fileInput(inputId = 'fileid2', label = 'Elija el Archivo CSV de los códigos de las OBPP'),
                                      width = 12
                                     ),
                                   box(
                                     
                                     
                                     
                                     solidHeader = T, 
                                     width = 12, column(12, align="center", 
                                                        actionButton(inputId = 'bot', label = 'Aceptar' ),
                                                        actionButton(inputId = 'bot2', label = 'Regresar'))),
                                     
                                     
                                     
                                     
                                     
                                     
                                     
                                     
                                   
                                  box(
                                      box(hidden(htmlOutput('mostraralgo')), width = 4),
                                      box(hidden(
                                        htmlOutput("titulo2"), 
                                        htmlOutput("comunicacion2")), width = 8
                                        ),
                                      
                                      width = 12),
                                   ),
                               
                               
                               
                               
                               tabItem(tabName = 'borrador', 
                                       dataTableOutput('file')),
                               tabItem('code_sinco', 
                                       dataTableOutput('fie')),
                               tabItem(tabName = 'pasos',
                                       box(width = 12,HTML('<h1 style=" color:blue">Cambios Generados Por La Aplicación</h1>')),
                                       htmlOutput("texto"))
                           )
                           
                       )
))
