library(lubridate)
library(dplyr)
library(tidyr)
library(leaflet)
library(sp)
library(rgdal)
library(tidyverse)
library(sf)


data_comunicaciones <- read.csv('/home/analista/Github/Archivos/Trabajo/mapa_aprobados/datas/ept_com.comunicaciones (3).csv')

data_comunicacionesx <- data_comunicaciones %>%
  left_join(data2 %>% select(obpp_situr_code,fecha_apro), by=c('codigo_situr'='obpp_situr_code')) %>% 
  filter(!is.na(fecha_apro)) 

data_comunicacionesx2 <- data_comunicacionesx %>% 
  mutate(create_date = date(create_date)) %>%
  mutate(valido = create_date > fecha_apro ) %>% 
  filter(valido == TRUE)


# #-----------------------------------------------------------------------------------------------------------------
# 
resumen_comunicaciones <- data_comunicacionesx2 %>% group_by(asunto_id2.name) %>% tally() %>% arrange(desc(n))


archivo_csv <- function(x){
  if(grepl('.csv$', x)){
    return(read.csv(x, stringsAsFactors = F))
  } else {return(NULL)}}

