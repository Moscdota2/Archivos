library(shiny)
library(shinydashboard)
library(leaflet)
library(sp)
library(rgdal)
library(tidyverse)
library(sf)

ui <- fluidPage(
  
  dashboardPage(skin = 'black',
                dashboardHeader(title = "Mapa de Aprobados"),
                dashboardSidebar(width = 260,
                                 sidebarMenu(
                                   menuItem("Inicio", tabName = "inicio", icon = icon("home")),
                                   menuItem("Información", tabName = "info", icon = icon("envelope")))
                                
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
                          column(12, align="center", leafletOutput(outputId = 'mapa'))),
                      box(solidHeader = T, width =6,
                          column(12, radioButtons(inputId = 'action', label = 'Opciones', choices = c('Proyectos'='all',
                                                                                                      'Firmados' = 'true',
                                                                                                      'No Firmados' = 'false',
                                                                                                      'Retrasados ' = 'retrasado')),
                                 selectInput(inputId = 'estados', label = 'Estados', choices = unique(data2$obpp_estado))))
                            
                    )
                  )
                  
                )
  )
)