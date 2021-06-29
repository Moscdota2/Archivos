library(shiny)
library(shinydashboard)
library(leaflet)
library(sp)
library(rgdal)
library(tidyverse)
library(sf)

source('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/funcion_latlong.R')

ui <- fluidPage(
  
  dashboardPage(skin = 'black',
                dashboardHeader(title = "Mapa de Aprobados"),
                dashboardSidebar(width = 260,
                                 sidebarMenu(
                                   menuItem("Inicio", tabName = "inicio", icon = icon("home")),
                                   menuItem("Información", tabName = "info", icon = icon("envelope")),
                                   menuItem('Carga de Archivos', tabName = 'carga', icon = icon('ad')))
                                
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
                      fluidPage(box(htmlOutput('titulo'), width = 12)),
                      
                      fluidPage(box(
                        solidHeader = T, 
                        width =12,
                        checkboxGroupInput(inputId = 'action', label = 'Opciones', choices = c('Retrasados ' = TRUE)),
                        checkboxGroupInput(inputId = 'action2', label = 'Firmados', choices = c('SI'=TRUE,'NO'=FALSE), selected=c(TRUE,FALSE)),
                        selectInput(inputId = 'estados', label = 'Estados', choices = estados, selected = 'GENERAL', multiple = TRUE),
                        selectInput(inputId = 'mes', label = 'Mes de Aprobacion', choices = c(3,5), selected = c(3,5), multiple = TRUE),
                        actionButton(inputId = 'mostrar_mapa', label = 'Mostrar'))
                        
                      ),
                      fluidPage(box(width = 12,
                        infoBoxOutput('proyecto'),
                        infoBoxOutput('firnado'),
                        infoBoxOutput('nofirmado'),
                        infoBoxOutput('retrasado')),
                        
                        fluidPage(box(solidHeader = T, 
                                      width = 12, 
                                      leafletOutput(outputId = 'mapa'),
                                      valueBoxOutput(outputId = 'valores')
                        )),
                        fluidPage(box(
                          textInput('code_mapa', 'Código de Proyecto Selecionado'),
                          actionButton(inputId = 'ver', label = 'Ver mas información')),
                      ),
                      fluidPage(box(width = 12,
                        tableOutput(outputId = 'comunicaciones'))
                      ),
                      fluidPage(box(width = 12,
                                    tableOutput(outputId = 'estados_retrasados'))
                      )
                    )
                    
                  ),
                  tabItem(
                    tabName = 'carga',
                    htmlOutput('carga_datos')
                  )
                  
                )
  )
)
)
