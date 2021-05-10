lugares <- c('Euphoria', 'Mango´s', 'Full Caña', 'La Parada Del Oso')
long <- c(-67.350414, -67.354116, -67.354012, -67.357935)
lat <- c(9.919347, 9.920894, 9.921073, 9.912982)

df <- data.frame(lugares, long, lat)

library(sf)
library(dplyr)
library(leaflet)
library(rgdal)
library(sp)
library(tidyverse).

popup_mapa <- paste('<b>Discoteca: </b>',df$lugares)

m <- leaflet() %>%
  addTiles() %>%
  setView(lng = -67.354012, 9.921073, 14) %>%
  addCircleMarkers(lng = df$long , lat = df$lat , color = 'red', label =df$lugares , popup = popup_mapa)
m
