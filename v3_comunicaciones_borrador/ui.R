library(shiny)
library(shinydashboard)
    
 ui <- fluidPage(#Leo
  dashboardPage( skin = 'black',
       dashboardHeader(title = "Devolución a Borrador"),
      dashboardSidebar(
      sidebarMenu(
     menuItem("Inicio", tabName = "inicio", icon = icon("th")),
    menuItem("Información", tabName = "info", icon = icon("th")),
    menuItem("Data Borrador", tabName = "borrador"),
    menuItem("Data Códigos SINCO", tabName = "code_sinco"),
    menuItem("Acciones hechas por el programa", tabName = 'pasos')
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
                                   box(fileInput(inputId = 'fileid', label = "Elija el Archivo de Borrador .Excel"),
                                       fileInput(inputId = 'fileid2', label = 'Elija el Archivo CSV de los códigos de las OBPP'),
                                       actionButton(inputId = 'bot', label = 'Aceptar'), 
                                       
                                       #
                                    )
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
