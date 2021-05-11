#librerias
library(rgdal)
library(dplyr)
library(sp)
library(DT)
library(geosphere)


funcion.utm.LatLong2 <- function(este,norte,huso){
  
  #convirtiendo a numerico
  este <- as.numeric(este)
  norte <- as.numeric(norte)
  huso <- as.numeric(huso)
  
  #asignado a vectores, el n se utiliza para ordenar 
  x <- este
  y <- norte
  h <- huso
  n <- 1:length(x)
  
  dataCoordenada <- data.frame(n = n, x = x, y = y, h = h)
  
  husos <- unique(dataCoordenada$h)
  datalatlon <- data.frame(n = NULL, x = NULL, y = NULL)
  
  for(i in 1:length(husos)){
    print(husos[i])
    
    if(husos[i] %in% c(18,19,20,21)){
      zona <- paste("+proj=utm +zone=",husos[i],sep = "") 
      dataCoordenadaHuso <- dataCoordenada[dataCoordenada$h == husos[i], ]
      utmcoor <- SpatialPoints(data.frame(x = dataCoordenadaHuso$x, y = dataCoordenadaHuso$y), proj4string=CRS(zona))
      longlatcoor<-spTransform(utmcoor,CRS("+proj=longlat"))
      dataCoordenadalatlon <- cbind(dataCoordenadaHuso$n,as.data.frame(longlatcoor))      
    }else{
      dataCoordenadaHuso <- dataCoordenada[dataCoordenada$h == husos[i], ]
      dataCoordenadalatlon <- data.frame(n = dataCoordenadaHuso$n, x = rep(0,nrow(dataCoordenadaHuso)), y = rep(0,nrow(dataCoordenadaHuso)))
    }
    
    names(dataCoordenadalatlon) <- c("n","long","lat")
    datalatlon <- rbind(datalatlon,dataCoordenadalatlon)
  }
  
  
  datalatlon <- datalatlon %>% arrange(n)
  
  
  return(datalatlon)
  
}