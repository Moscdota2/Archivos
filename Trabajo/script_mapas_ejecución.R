library(lubridate)
library(dplyr)
library(tidyr)
library(leaflet)
library(sp)
library(rgdal)
library(tidyverse)
library(sf)

data <- read.csv('Escritorio/sico.csv', stringsAsFactors = FALSE)
data_historial <- read.csv('Escritorio/sico2.csv', stringsAsFactors = FALSE)

source('Trabajo/funcion_latlong.R')


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


dataz <- data2 %>% filter(obpp_estado %in% c("ZULIA","GUÁRICO"))

color <- if_else(dataz$firmados_true, 'red', if_else(dataz$retrasados,'#B725CB','blue'))
popup_mapa <- paste('<b>Proyecto: </b>',dataz$project_ids.display_name)


mapa <- leaflet() %>%
  setView(lng = -66.58973, lat = 6.42375, zoom =5.5) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = dataz$long, 
    lat = dataz$lat,
    color = color, 
    label = dataz$firmados_true, 
    popup = popup_mapa,
    stroke = FALSE,
    fillOpacity = 0.8)


mapa

# por estado, por mes de aprobación y si los que están retrasados
# shiny dashboard
# mas nada
#