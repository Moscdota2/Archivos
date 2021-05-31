  library(sf)
library(leaflet)
library(dplyr)
library(rgdal)
library(tidyverse)

#estados <- readOGR("Escritorio/Cartografia/venezuela_estados.shp")
estados2 <- read_sf("/home/analista/Trabajo/Mapas Trabajo/Estados_Venezuela.shp")
load('/home/analista/Trabajo/Data_Mapas/salida.RData')

x <- x %>% filter(!is.na(lat) & !is.na(long))

color <- if_else(x$investment_sector_id.name == 'SOCIOPRODUCTIVOS', '#0300FF', '#FFE100')
popup_mapa <- paste('<b>Proyecto: </b>',x$project_ids.display_name)
mapa2 <- leaflet(estados2) %>% 
  addTiles() %>%
  setView(lng = -66.58973, lat = 6.42375, zoom =5.5) %>%
  addPolygons(color = "#444444", weight = 5, smoothFactor = 0.5, opacity = 3, fillOpacity = 0.5) %>% 
  addCircleMarkers(lng = x$long, lat = x$lat, color = ~color , label = x$investment_sector_id.name, popup = popup_mapa)

mapa2

#punto a evaluar long lat
pnts <- c(-64.00901,10.91314)

#converitmos el punto en clase sf
pnts <- st_point(x=pnts)

#intecerptamos un punto geografico en el mapa
resul_of_intersec <- st_intersects(pnts, estados2)

#convertimos el resultado (posicion en el df) a tipo numerico
resul_of_intersec <- as.numeric(resul_of_intersec)

#obtenemos el resultado en variable
result_state = estados2[resul_of_intersec, ]$ESTADO

result_state

x$obpp_estado <- trimws(chartr('áéíóú','aeiou',tolower(x$obpp_estado)))
estados2$ESTADO <- trimws(chartr('áéíóú','aeiou',tolower(estados2$ESTADO)))

resultados_intercepcion <- NULL

for(i in 1:nrow(x)){
  pnts <- c(x$project_ids.display_name[i, 'long'], x$project_ids.display_name[i, 'lat'])
  pnts <- st_point(x=pnts)
  resul_of_intersec <- st_intersects(pnts, estados2)
  resul_of_intersec <- as.numeric(resul_of_intersec)
  resul_of_intersec <- as.numeric(resul_of_intersec)
  result_state = estados2[resul_of_intersec, ]$ESTADO
  resultados_intercepcion <- c(resultados_intercepcion, result_state)
}

proyectos$intercepcion <- resultados_intercepcion

comparador <- if_else(estados2$ESTADO  == x$obpp_estado, paste0('<b> "Es Verdadero" <b>'), '<b>" Es Falso" <b>')
