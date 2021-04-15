library(shiny)
library(shinydashboard)
library(shinyjs)
library(readxl)
library(dplyr)


ui <- fluidPage(#Leo
  useShinyjs(),
  dashboardPage(skin = 'black',
                dashboardHeader(title = "Devolución a Borrador"),
                dashboardSidebar(width = 260,
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
                       fluidPage(fluidPage(box(solidHeader = T, 
                           width = 12, column(12, align="center", imageOutput('alcaravan_png',height = "200px")))),
                       fluidPage(box(solidHeader = F, 
                           width = 12, column(12, align="center", imageOutput('sinco_png', height = "375px")))))
                     ),
                     tabItem(
                       tabName = 'info',
                       htmlOutput('carga_datos'),
                       box(solidHeader = T, width = 12, 
                           column(12, align="center",
                                  actionButton(inputId = 'bot', label = 'Aceptar'),
                                  actionButton(inputId = 'bot2', label = 'Regresar'))),
                       
                       
                       
                      hidden(htmlOutput('mostrar_asuntos'))
                     ),
                     tabItem(tabName = 'borrador', 
                             dataTableOutput('file')),
                     tabItem('code_sinco', 
                             dataTableOutput('fie')),
                     tabItem(tabName = 'pasos',
                             fluidPage(box(width = 12,HTML('<h1 style=" color:blue">Cambios Generados Por La Aplicación</h1>'))),
                             fluidPage(htmlOutput("texto")))
                   )
                   
                 )
  ))
