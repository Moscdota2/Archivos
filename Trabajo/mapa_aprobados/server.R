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

source('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/funcion_latlong.R')

shinyServer(function(input, output, session) {
  
  output$alcaravan_png <- renderImage({
    list(src = 'WWW/photo_2021-04-12_13-37-57.jpg',
         width = 600)
  })
  
  output$sinco_png <- renderImage({
    list(src = 'WWW/logo_sinco.png',
         width = 600)
  })
  
  #------------------------------------------#
  
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
  
  #------------------------------------------#

  observeEvent(input$bot, {
  if(is.null(input$fileid) ||is.null(input$fileid2) || is.null(input$fileid3)){
    print('<strong>Cargue Archivo</strong>')
  }else{
    data2 <- datamapa()
    data_historial_apro <- data_h_apro()
    data_historial_edd <- data_h_edd()
    data_comunicacionesx <- datacomunicacionex()
    data_comunicacionesx2 <- datacomx2()
    resumen_comunicaciones <- dataresumen()
    #petro_amountt <- data2
    save(data2, data_historial_apro, data_historial_edd, data_comunicacionesx, data_comunicacionesx2, resumen_comunicaciones, file = './cache.RData')
  }
  })
  
  output$carga_datos <- renderUI({
    fluidPage(
      box(fileInput(inputId = 'fileid', label = "Cargue el archivo de los Proyectos Aprobados", accept = '.csv'),
          fileInput(inputId = 'fileid2', label = "Cargue el archivo de la Historia", accept = '.csv'),
          fileInput(inputId = 'fileid3', label = "Cargue el archivo de Comunicaciones", accept = '.csv'),
          fileInput(inputId = 'fileid4', label = "Cargue el archivo de monto de Petros", accept = '.csv'),
          actionButton(inputId = 'bot', label = 'Aceptar', icon('retweet'))
         )
    )
  })
  
  resumen_comunicaciones_mapa <- reactive({

    situr <- datamapa() %>% select(obpp_situr_code) %>% pull(obpp_situr_code)
    resumen_comunicaciones <- datacomx2() %>% filter(codigo_situr %in% situr) %>% group_by(asunto_id2.name) %>% tally() %>% arrange(desc(n))
    resumen_comunicaciones
    
  })
  
  data_h_apro <- reactive({
    if(is.null(input$fileid2)){
      data_historial_apro <- data_historial_apro
    } else {
      datah <- archivo_csv(input$fileid2$datapath)
      datah[datah$code == '', 'code'] <- NA
      datah <- datah %>% mutate(code2 = code) %>%  fill(code)
      datah <- datah %>% filter(project_timeline_ids.create_date != '')
      datah <- datah %>% 
        mutate(project_timeline_ids.create_date = ymd_hms(project_timeline_ids.create_date)) %>% 
        mutate(project_timeline_ids.create_date =  date(project_timeline_ids.create_date))
      
      data_h_apro <- datah %>% 
        filter(project_timeline_ids.descripcion == 'Proyecto Aprobado ') %>% 
        select(code, project_timeline_ids.create_date) %>% 
        rename(fecha_apro = project_timeline_ids.create_date) %>% 
        distinct() %>% 
        group_by(code) %>% 
        summarise(fecha_apro = first(fecha_apro))
      
      }  
  })
  
  data_h_edd <- reactive({
    
    if(is.null(input$fileid2)){
      data_historial_edd <- data_historial_edd
    } else {
      datah <- archivo_csv(input$fileid2$datapath)
      datah[datah$code == '', 'code'] <- NA
      datah <- datah %>% mutate(code2 = code) %>%  fill(code)
      datah <- datah %>% filter(project_timeline_ids.create_date != '')
      datah <- datah %>% 
        mutate(project_timeline_ids.create_date = ymd_hms(project_timeline_ids.create_date)) %>% 
        mutate(project_timeline_ids.create_date =  date(project_timeline_ids.create_date))

      data_h_edd <- datah %>% filter(project_timeline_ids.descripcion %in% 'Proyecto se encuentra a la espera de Desembolso') %>% 
        group_by(code) %>% 
        summarise(fecha_edd = first(project_timeline_ids.create_date))
    }
    
  })

  datamapa <- reactive({
    
    
    #petro_amountt <- montopetros()
    
    if(is.null(input$fileid)){
      load('./cache.RData')
      datax <- data2
    } else {
      
      datax <- archivo_csv(input$fileid$datapath)
      
      datax <- datax %>% left_join(data_h_apro(), by='code') %>% left_join(data_h_edd(), by='code')
      resta_firmados <- datax %>% mutate(firmados = fecha_edd - fecha_apro)
      resta_nofirmados <- datax %>% mutate(tiempo_actual = today() - fecha_apro)
      datax <- datax %>% left_join(resta_firmados) %>% left_join(resta_nofirmados)

      datax <- datax %>% mutate(firmados_true =
                                  ifelse(!is.na(firmados), T, F)) %>%
        mutate(retrasados = ifelse(firmados_true == F & as.numeric(tiempo_actual) > (30), T, F))

      datax <- datax %>% mutate(mes = month(datax$fecha_apro))
      datax <- datax %>% filter(!is.na(fecha_apro))
      datax$utm_zone_id.id <- gsub('sinco_project.','',datax$utm_zone_id.id)
      datax$utm_zone_id.id <- as.numeric(datax$utm_zone_id.id)
      coord <- funcion.utm.LatLong2(huso = datax$utm_zone_id.id, este = datax$utm_east, norte = datax$utm_north)
      datax <- datax %>% cbind(coord)
      color <- if_else(datax$firmados_true, 'red', if_else(datax$retrasados,'#B725CB','blue'))
      popup_mapa <- paste('<b>Proyecto: </b>',datax$project_ids.display_name)
      
      
      data_petros <- archivo_csv(input$fileid4$datapath)
      #data_petros <- data_petros %>% rename(code = Referencia, id = External.ID, petro_amount = Monto.en.petro)
      petro_amountt <- data_petros %>%  select(petro_amount, code)
      datax <- datax %>% left_join(petro_amountt)
      
    }
    
   
    
    
    if(!is.null(input$action2) & !is.null(input$estados)){
      datax <- datax %>% filter(firmados_true %in% input$action2)
      if(!input$estados %in% 'GENERAL'){
        datax <- datax %>% filter(obpp_estado %in% input$estados)
      }
    }else{
      datax <- datax %>% filter(obpp_estado %in% 'xxx')
    }
    
    if(!is.null(input$action)){
      if(input$action == TRUE){
        datax <- datax %>% filter(retrasados %in% input$action)
      }
    }
    
    if(!is.null(input$mes)){
      datax <- datax %>% filter(mes %in% input$mes)
    }else{
      datax <- datax %>% filter(mes %in% 121)
    }
    
    datax
    
  })
  
  datacomunicacionex <- reactive({
    
    datax <- datamapa()
    com2 <- archivo_csv(input$fileid3$datapath)

    if(is.null(input$fileid3)){
      data_comunicacionesx <- data_comunicacionesx
    } else {
      com1 <- com2 %>%
        left_join(datax %>% select(obpp_situr_code,fecha_apro), by=c('codigo_situr'='obpp_situr_code')) %>%
        filter(!is.na(fecha_apro))
    }
    
  })
  
  datacomx2 <- reactive({
    if(is.null(input$fileid3)){
      data_comunicacionesx2 <- data_comunicacionesx2
    } else {
    com4 <- datacomunicacionex() %>% 
      mutate(create_date = date(create_date)) %>%
      mutate(valido = create_date > fecha_apro ) %>% 
      filter(valido == TRUE)
    }
  })
  
  dataresumen <- reactive({
    
    codigo_situr_proyecto <- datamapa() %>% pull(obpp_situr_code)
    
    if(is.null(input$fileid3)){
      com3 <- datacomx2() %>% group_by(asunto_id2.name) %>% filter(codigo_situr %in% codigo_situr_proyecto)%>% tally() %>% arrange(desc(n))
    } else {
    com3 <- datacomx2() %>% group_by(asunto_id2.name) %>% tally() %>% arrange(desc(n))
    }
    
    com3
  })
  
 
 
  
  #----------------------------------------------#

  output$mapa <- renderLeaflet({

    leaflet() %>%
      setView(lng = -66.58973, lat = 6.42375, zoom =5.5) %>%
      addTiles()
      
    })
  
  output$comunicaciones <- renderTable({
    dataresumen()
  })
  
  
  output$estados_retrasados <- renderTable({
    datos <- datamapa() %>% filter(retrasados == T) %>%  group_by(obpp_estado) %>% tally() %>% arrange(desc(n))
    names(datos) <- c('Estados Retrasados', 'Número')
    datos
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
        '<hr>'
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