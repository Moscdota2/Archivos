library(shiny)
library(shinydashboard)
library(dplyr)
    
 ui <- fluidPage(#Leo
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
                                   htmlOutput('titulo'),
                                   box(solidHeader = F, 
                                       width = 12, column(12, align="center", imageOutput('alcaravan_png',height = "200px"))),
                                   box(solidHeader = F, 
                                       width = 12, column(12, align="center", imageOutput('sinco_png', height = "375px")))
                               ),
                               tabItem(
                                   tabName = 'info',
                                   #################################################################################################
                                   box(fileInput(inputId = 'fileid', label = "Elija el Archivo de Borrador .Excel"),
                                       fileInput(inputId = 'fileid2', label = 'Elija el Archivo CSV de los códigos de las OBPP'),
                                       actionButton(inputId = 'bot', label = 'Aceptar'),
                                   ),
                                   ################################################################################################
                                   box(HTML('<h3>Estatus de Respuesta</h3>'),
                                        htmlOutput('estatus'),
                                        HTML('<h3>Tipo de NO Respondidas</h3>'),
                                        htmlOutput('estandar'),
                                        downloadLink("descarga_no_estandar", "Descargar proyectos con comunicaciones no estandar"),
                                        HTML('<h3>Evaluados</h3>'),
                                        htmlOutput('estatus_proyecto'),
                                        downloadLink("descarga_evaluados", "Descargar proyectos ya evaluados"),
                                        HTML('<h3>Respuestas estandar</h3>'),
                                        htmlOutput(("respuestas_estandar"))
                                       ),
                                       box(mainPanel(
                                         htmlOutput("titulo2"),
                                         htmlOutput("comunicacion2")),
                                       
                                     
                               ),
                               
                               ),
                               
                               tabItem(tabName = 'borrador', 
                                       box(dataTableOutput('file'))),
                               tabItem('code_sinco', 
                                       box(dataTableOutput('fie'))),
                               tabItem(tabName = 'pasos',
                                       htmlOutput("texto"))
                           )
                           
                       )
))
