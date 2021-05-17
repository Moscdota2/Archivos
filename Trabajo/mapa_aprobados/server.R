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

shinyServer(function(input, output, session) {
  
  
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
  
  output$titulo <- renderUI({
    
    HTML('<h1 style="color: blue">Proyectos en Estatus Aprobados</h1>')
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

  observeEvent(input$mapa_marker_click, {
    
    data_aux <- datamapa()
    
    data_aux$lat <- round(as.numeric(data_aux$lat),6)
    data_aux$long <- round(as.numeric(data_aux$long),6)
    
    lat_mapa = round(as.numeric(input$mapa_marker_click$lat),6)
    lng_mapa = round(as.numeric(input$mapa_marker_click$lng),6)
    
    codigo <- data_aux %>% filter(lat == lat_mapa, long == lng_mapa) %>% pull(code)
    
    updateTextInput(session, inputId = 'code_mapa', value = codigo)
    print(codigo)
    
  })
  
  observeEvent(input$ver, {
    
    data_aux1 <- datamapa()
    
    data_aux1 <- data_aux1 %>% filter(code %in% input$code_mapa)
    
    # territ <- territorial %>% filter(code %in% input$code_mapa)
    # comun <- resumen_comunicaciones %>% filter(situr == data_aux1$obpp_situr_code) %>% pull(asunto)
    
    # if(length(comun) > 0){
    #   comun <- paste0(comun, collapse = ', ')
    # }else{
    #   comun <- c('Sin Comunicaciones')
    # }
    
    showModal(modalDialog(
      title = paste("Proyecto", input$code_mapa),
      HTML(
        '<hr>',
        '<b>Datos OBPP</b>','<br>',
        '<hr>',
        '<b>Situr:</b>',data_aux1$obpp_situr_code, '<br>',
        '<b>OBPP:</b>',data_aux1$obpp_name, '<br>',
        '<b>Estado:</b>',data_aux1$obpp_estado, '<br>',
        '<b>Municipio:</b>',data_aux1$obpp_municipio, '<br>',
        # '<b>Rif:</b>',data_aux1$rif, '<br>',
        # '<b>Cuenta Bancaria:</b>',data_aux1$cuenta, '<br>',
        '<hr>',
        '<b>Datos Proyecto</b>','<br>',
        '<hr>',
        '<b>Código:</b>',data_aux1$code, '<br>',
        '<b>Proyecto:</b>',data_aux1$project_ids.display_name, '<br>',
        '<b>Subcategoría:</b>', data_aux1$subcategory_id.name, '<br>',
        '<b>Monto (Petro):</b>', data_aux1$petro_amount, '<br>',
        '<hr>',
        '<b>Datos Firma de Convenio</b>','<br>',
        '<hr>',
        '<b>Fecha Aprobacion:</b>', as.character(data_aux1$fecha_apro),'<br>',
        '<b>Firmó Convenio:</b>', data_aux1$firmados_true,'<br>',
        '<b>Fecha de Firma de Convenio:</b>', as.character(data_aux1$fecha_edd),'<br>',
        '<hr>',
        # '<b>Datos Comunicaciones</b>','<br>',
        # '<hr>',
        # # '<b>Comunicaciones:</b>', comun,'<br>',
        # '<hr>',
        # '<b>Datos Programación</b>','<br>',
        # '<hr>',
        # '<b>Fecha Programación Firma:</b>', as.character(territ$fecha_programacion_firma),'<br>',
        # '<b>Reprogramado:</b>', as.character(territ$reprogramado),'<br>',
        # '<b>Vocero Contactado:</b>', territ$vocero,'<br>',
        # '<b>Fecha Contacto:</b>', as.character(territ$fecha_contacto),'<br>',
        # '<b>Observaciones:</b>', territ$observaciones,'<br>'
      ),
      easyClose = TRUE,
      footer = paste('Días desde Aprobación:', data_aux1$tiempo_actual)
    )
    )
  })
  
  
  
  observeEvent(input$mostrar_mapa, {
    
    datas_true <- datamapa()

    tryCatch({
      
      color <- if_else(datas_true$firmados_true, 'red', if_else(datas_true$retrasados,'#B725CB','blue'))
      popup_mapa <- paste('<b>Código de proyecto: </b>',datas_true$code, '<br>',
                          '<b>Nombre del proyecto: </b>', datas_true$project_ids.display_name, '<br>',
                          '<b>Nombre de OBPP: </b>', datas_true$obpp_name, '<br>',
                          '<b>Categoría: </b>', datas_true$category_id.name, '<br>',
                          '<b>Subcategoría: </b>', datas_true$subcategory_id.name, '<br>',
                          '<b>Monto: </b>', datas_true$amount, '<br>',
                          '<b>Monto en Petro: </b>', datas_true$petro_amount, '<br>',
                          '<b>Fecha de Aprobación: </b>', datas_true$fecha_apro, '<br>',
                          '<b>Fecha de Firma: </b>', datas_true$fecha_edd)
      
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