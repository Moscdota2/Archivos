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
                      
                      box(solidHeader = T, 
                          width = 12, 
                          leafletOutput(outputId = 'mapa'),
                          valueBoxOutput(outputId = 'valores')
                          ),
                      
                      box(
                        solidHeader = T, 
                        width =6,
                        checkboxGroupInput(inputId = 'action', label = 'Opciones', choices = c('Retrasados ' = TRUE)),
                        checkboxGroupInput(inputId = 'action2', label = 'Firmados', choices = c('SI'=TRUE,'NO'=FALSE)),
                        selectInput(inputId = 'estados', label = 'Estados', choices = estados, selected = 'GENERAL', multiple = TRUE),
                        actionButton(inputId = 'mostrar_mapa', label = 'Mostrar')
                      ),
                      box(
                        infoBoxOutput('proyecto'),
                        infoBoxOutput('firnado'),
                        infoBoxOutput('nofirmado'),
                        infoBoxOutput('retrasado')
                      ),
                      box(
                        tableOutput(outputId = 'comunicaciones')
                      )
                    )
                  )
                  
                )
  )
)
