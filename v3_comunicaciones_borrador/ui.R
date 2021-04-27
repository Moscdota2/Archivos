library(shiny)
library(shinydashboard)
library(shinyjs)
library(readxl)
library(dplyr)
library(tidyr)
library(lubridate)
library(tidyr)
library(DT)

ui <- fluidPage(
  useShinyjs(),
  dashboardPage(skin = 'black',
                dashboardHeader(title = "Devolución a Borrador"),
                dashboardSidebar(width = 260,
                                  sidebarMenu(
                                  menuItem("Inicio", tabName = "inicio", icon = icon("home")),
                                  menuItem("Información", tabName = "info", icon = icon("envelope")),
                                  menuItem("Data Borrador", tabName = "borrador",icon = icon("folder-open")),
                                  menuItem("Data Códigos SINCO", tabName = "code_sinco", icon = icon("folder-open")),
                                  menuItem("Acciones hechas por el programa", tabName = 'pasos', icon = icon("info")),
                                  menuItem('Alerta', tabName = 'alertaui', icon = icon('warning'))
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
                                  actionButton(inputId = 'bot', label = 'Aceptar', icon('retweet')))),
                       
                      hidden(htmlOutput('mostrar_asuntos'))
                     ),
                     tabItem(tabName = 'borrador', 
                             DTOutput('file')),
                     tabItem('code_sinco', 
                             DTOutput('fie')),
                     tabItem(tabName = 'pasos',
                             fluidPage(box(width = 12,HTML('<h1 style=" color:blue">Cambios Generados Por La Aplicación</h1>'))),
                             fluidPage(htmlOutput("texto"))),
                     tabItem(tabName = 'alertaui',
                             fluidPage(box(width = 12,
                               HTML('<h1>Alerta</h1>')
                             )),
                             fluidPage(box(width = 12,
                                          htmlOutput('alerta'),
                                          actionButton(inputId = 'botalerta', label = 'Aceptar'))),
                             hidden(htmlOutput('alerta2'))
                             
                     )
                   )
                   
                 )
  )) 
