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

load('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/datas.RData')

shinyServer(function(input, output) {
  
  source('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/script_mapas_ejecución.R')
  # load('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/datas.RData')
  
  data <- read.csv('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/sico.csv', stringsAsFactors = FALSE)
  data_historial <- read.csv('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/sico2.csv', stringsAsFactors = FALSE)
  
  output$alcaravan_png <- renderImage({
    list(src = 'WWW/photo_2021-04-12_13-37-57.jpg',
         width = 600)
  })
  
  output$sinco_png <- renderImage({
    list(src = 'WWW/logo_sinco.png',
         width = 600)
  })
  
  datamapa <- reactive({

    data_historial[data_historial$code == '', 'code'] <- NA

    data_historial <- data_historial %>% mutate(code2 = code) %>%  fill(code)

    data_historial <- data_historial %>% filter(project_timeline_ids.create_date != '')

    data_historial <- data_historial %>%
      mutate(project_timeline_ids.create_date = ymd_hms(project_timeline_ids.create_date)) %>%
      mutate(project_timeline_ids.create_date =  date(project_timeline_ids.create_date))

    #-------------------------------------------------------------------------------------------------
    data_historial_apro <- data_historial %>%
      filter(project_timeline_ids.descripcion == 'Proyecto Aprobado ') %>%
      select(code, project_timeline_ids.create_date) %>%
      rename(fecha_apro = project_timeline_ids.create_date) %>%
      distinct() %>%
      group_by(code) %>%
      summarise(fecha_apro = first(fecha_apro))

    data_historial_edd <- data_historial %>% filter(project_timeline_ids.descripcion %in% 'Proyecto se encuentra a la espera de Desembolso') %>%
      group_by(code) %>%
      summarise(fecha_edd = first(project_timeline_ids.create_date))

    #-----------------------------------------------------------------------------------------------------

    data2 <- data %>% left_join(data_historial_apro, by='code') %>% left_join(data_historial_edd, by='code')

    #tiempo hasta la firma

    resta_firmados <- data2 %>% mutate(firmados = fecha_edd - fecha_apro)
    resta_nofirmados <- data2 %>% mutate(tiempo_actual = today() - fecha_apro)
    data2 <- data2 %>% left_join(resta_firmados) %>% left_join(resta_nofirmados)

    data2 <- data2 %>% mutate(firmados_true =
                                ifelse(!is.na(firmados), T, F)) %>%
      mutate(retrasados = ifelse(firmados_true == F & as.numeric(tiempo_actual) > (30), T, F))

    data2 <- data2 %>% mutate(mes = month(data2$fecha_apro))



    data2$utm_zone_id.id <- gsub('sinco_project.','',data2$utm_zone_id.id)
    data2$utm_zone_id.id <- as.numeric(data2$utm_zone_id.id)


    coord <- funcion.utm.LatLong2(huso = data2$utm_zone_id.id, este = data2$utm_east, norte = data2$utm_north)

    data2 <- data2 %>% cbind(coord)
  })

  output$mapa <- renderLeaflet({

    leaflet() %>%
      setView(lng = -66.58973, lat = 6.42375, zoom =5.5) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = data2$long,
        lat = data2$lat,
        color = color,
        label = data2$firmados_true,
        popup = popup_mapa,
        stroke = FALSE,
        fillOpacity = 0.8)
      
    })
  
  observeEvent(input$action, {
    if (input$action == "true") {
      datas_true <- data2[data2$firmados_true == TRUE,]
      
      leafletProxy("mapa") %>%
        clearMarkers() %>%
        clearShapes() %>%
        addCircleMarkers(data = datas_true,
                         lng  = datas_true$long,
                         lat  = datas_true$lat,
                         radius = 8,
                         weight = 10,
                         color ='red',
                         popup = popup_mapa,
                         stroke = FALSE,
                         fillOpacity = 0.8, 
                         label = datas_true$firmados_true)

        } else if (input$action == "false") {
          datas_false <- data2[data2$firmados_true == F,]
          
          leafletProxy("mapa") %>%
            clearMarkers() %>%
            clearShapes() %>%
            addCircleMarkers(data = datas_false,
                             lng  = datas_false$long,
                             lat  = datas_false$lat,
                             radius = 8,
                             weight = 10,
                             color ='blue',
                             popup = popup_mapa,
                             stroke = FALSE,
                             fillOpacity = 0.8, 
                             label = datas_false$firmados_true)
          
        } else if (input$action == 'all'){
          
          leafletProxy("mapa") %>%
            clearMarkers() %>%
            clearShapes() %>%
            addCircleMarkers(
              data = data2,
              lng = data2$long,
              radius = 8,
              weight = 10,
              lat = data2$lat,
              color = color,
              label = data2$firmados_true,
              popup = popup_mapa,
              stroke = FALSE,
              fillOpacity = 0.8)
          
        } else if (input$action == 'retrasado'){
      
          datas_retrasados <- data2[data2$retrasados == TRUE, ]
          
          leafletProxy("mapa") %>%
            clearMarkers() %>%
            clearShapes() %>%
            addCircleMarkers(data = datas_retrasados,
                             lng  = datas_retrasados$long,
                             lat  = datas_retrasados$lat,
                             radius = 8,
                             weight = 10,
                             color ='#B725CB',
                             popup = popup_mapa,
                             stroke = FALSE,
                             fillOpacity = 0.8, 
                             label = datas_retrasados$firmados_true)
          
    }
  }, ignoreInit = TRUE)

  observeEvent(input$estados, {

    dataz <- data2 %>% filter(obpp_estado %in% input$estados)
    
    leafletProxy("mapa") %>%
      clearMarkers() %>%
      clearShapes() %>%
      addCircleMarkers(data = dataz,
                       lng  = dataz$long,
                       lat  = dataz$lat,
                       radius = 8,
                       weight = 10,
                       color ='green',
                       popup = popup_mapa,
                       stroke = FALSE,
                       fillOpacity = 0.8, 
                       label = dataz$firmados_true)
    
    
  })
    
})
 


