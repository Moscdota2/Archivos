#cargando libreria
library(dplyr)
library(sf)

#cargamos el mapa formato sh
map = read_sf("/home/analista/Documentos/Documentos_Python/Jupyter/IRDpropuesta/datas_requeridas/estados_venezuela/Estados_Venezuela.shp")

#punto a evaluar long lat
pnts <- c(-64.00901,10.91314)

#converitmos el punto en clase sf
pnts <- st_point(x=pnts)

#intecerptamos un punto geografico en el mapa
resul_of_intersec <- st_intersects(pnts, map)

#convertimos el resultado (posicion en el df) a tipo numerico
resul_of_intersec <- as.numeric(resul_of_intersec)

#obtenemos el resultado en variable
result_state = map[resul_of_intersec, ]$ESTADO

#---------------------------------------------

resultados_intercepcion <- NULL

for(i in 1:nrow(proyectos)){
  pnts <- c(proyectos[i, 'long'], proyectos[i, 'lat'])
  pnts <- st_point(x=pnts)
  resul_of_intersec <- st_intersects(pnts, map)
  resul_of_intersec <- as.numeric(resul_of_intersec)
  resul_of_intersec <- as.numeric(resul_of_intersec)
  result_state = map[resul_of_intersec, ]$ESTADO
  resultados_intercepcion <- c(resultados_intercepcion, result_state)
}

proyectos$intercepcion <- resultados_intercepcion
  

# rchar(tolower(estado)) vs rchar(tolower(inteccepcion))
