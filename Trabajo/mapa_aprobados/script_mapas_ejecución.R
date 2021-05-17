library(lubridate)
library(dplyr)
library(tidyr)
library(leaflet)
library(sp)
library(rgdal)
library(tidyverse)
library(sf)


source('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/funcion_latlong.R')
data <- read.csv('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/sico.csv', stringsAsFactors = FALSE)
data_historial <- read.csv('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/sico2.csv', stringsAsFactors = FALSE)
data_petros <- read.csv('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/petros.csv', stringsAsFactors = F)

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

data2 <- data2 %>% filter(!is.na(fecha_apro))



data2$utm_zone_id.id <- gsub('sinco_project.','',data2$utm_zone_id.id)
data2$utm_zone_id.id <- as.numeric(data2$utm_zone_id.id)

estados <- c("GENERAL",
             "AMAZONAS",
             "ANZOÁTEGUI",
             "APURE",
             "ARAGUA",
             "BARINAS",
             "BOLÍVAR",
             "CARABOBO",
             "COJEDES",
             "DISTRITO CAPITAL",
             "FALCÓN",
             "GUÁRICO",
             "LARA",
             "MÉRIDA",
             "MIRANDA",
             "MONAGAS",
             "NUEVA ESPARTA",
             "PORTUGUESA",
             "SUCRE",
             "TÁCHIRA",
             "TRUJILLO",
             "YARACUY",
             "ZULIA")
 

coord <- funcion.utm.LatLong2(huso = data2$utm_zone_id.id, este = data2$utm_east, norte = data2$utm_north)

data2 <- data2 %>% cbind(coord)

color <- if_else(data2$firmados_true, 'red', if_else(data2$retrasados,'#B725CB','blue'))
popup_mapa <- paste('<b>Proyecto: </b>',data2$project_ids.display_name)

data_petros <- data_petros %>% rename(code = Referencia, id = External.ID, petro_amount = Monto.en.petro)
petro_amountt <- data_petros %>%  select(petro_amount, code)

data2 <- data2 %>% left_join(petro_amountt)

save(data2,
     data,
     data_historial_apro,
     data_historial_edd,
     resta_firmados,
     resta_nofirmados,
     coord,
     data_historial,
     color,
     popup_mapa,
     estados,
     file = '1datas.RData')

