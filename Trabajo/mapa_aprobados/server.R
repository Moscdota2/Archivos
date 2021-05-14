library(shiny)
library(shinydashboard)
library(lubridate)
library(dplyr)
library(tidyr)
library(leaflet)
library(sp)
library(rgdal)
library(tidyverse)
library(sf)

source('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/script_mapas_ejecución.R')
load('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/1datas.RData')

shinyServer(function(input, output) {
  
  
  output$alcaravan_png <- renderImage({
    list(src = 'WWW/photo_2021-04-12_13-37-57.jpg',
         width = 600)
  })
  
  output$sinco_png <- renderImage({
    list(src = 'WWW/logo_sinco.png',
         width = 600)
  })
  
  output$proyecto <- renderInfoBox({
    
    valor <- datamapa()  %>% count()
    
    infoBox(
      "Proyectos",
      valor,
      color = "aqua"
    )
  })
  
  output$firnado <- renderInfoBox({
    
    valor <- datamapa() %>%  filter(firmados_true == TRUE) %>% count()
    
    infoBox(
      "Firmado",
      valor,
      color = "blue"
    )
  })
  
  output$retrasado <- renderInfoBox({
    input$estados
    input$action
    
    valor <- datamapa() %>%  filter(retrasados == TRUE) %>% count()
    
    
    infoBox(
      "Retrasado",
      valor,
      color = "fuchsia"
    )
    
    
  })
  
  resumen_comunicaciones_mapa <- reactive({

    situr <- datamapa() %>% select(obpp_situr_code) %>% pull(obpp_situr_code)
    
    resumen_comunicaciones <- data_comunicacionesx2 %>% filter(codigo_situr %in% situr) %>% group_by(asunto_id2.name) %>% tally() %>% arrange(desc(n))
    
    resumen_comunicaciones
    
  })
  
  datamapa <- reactive({
    
    datax <- data2
    
    if(!is.null(input$action2) & !is.null(input$estados)){
      datax <- datax %>% filter(firmados_true %in% input$action2)
      if(!input$estados %in% 'GENERAL'){
        datax <- datax %>% filter(obpp_estado %in% input$estados)
      }
    }
    
    if(!is.null(input$action)){
      if(input$action == TRUE){
        datax <- datax %>% filter(retrasados %in% input$action)
      }
    }
    datax
  })

  output$mapa <- renderLeaflet({

    leaflet() %>%
      setView(lng = -66.58973, lat = 6.42375, zoom =5.5) %>%
      addTiles()
      
    })
  
  output$comunicaciones <- renderTable({
    resumen_comunicaciones_mapa()
  })
  
  
  observeEvent(input$mostrar_mapa, {
    
    datas_true <- datamapa()

    tryCatch({
      
      color <- if_else(datas_true$firmados_true, 'red', if_else(datas_true$retrasados,'#B725CB','blue'))
      popup_mapa <- paste('<b>Proyecto: </b>',datas_true$project_ids.display_name)
      
      leafletProxy(mapId = 'mapa', data = datas_true) %>%
        clearMarkers() %>%
        clearShapes() %>%
        addCircleMarkers(lng  = ~long,
                         lat  = ~lat,
                         radius = 8,
                         weight = 10,
                         color = color,
                         popup = popup_mapa,
                         stroke = FALSE,
                         fillOpacity = 0.8, 
                         label = ~firmados_true)
    }, error = function(e){
      print(e)
    })

  })
    
})