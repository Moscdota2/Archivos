library(dplyr)
library(readr)
library(lubridate)
library(xlsx)

data_1 <- read.csv("Trabajo/Tarea-12-03/ept_com.comunicaciones (1).csv")
data_2 <- read.csv('Trabajo/Tarea-12-03/ept_com.comunicaciones (2).csv')

data <- rbind(data_1, data_2)

source('Ejercicios R/Tareas Isaias/ejercicio_limpieza_html.R')
# funcion_html <- function(df){
#   library(dplyr)
#   library(tm)
#   library(tm.plugin.webmining)
#   library(readr)
#     x <- apply(df, 2, FUN = function(x) all(grepl("<.*?>", x) | grepl("^$", x)) & !all(grepl('^$', x)))
#     x <- names(x[x == TRUE])
#       for (i in 1:length(x)){
#         p <- df[, x[i]]
#         h <- as.character(p)
#         h <- as.list(h)
#         h <- sapply(h, FUN = extractHTMLStrip)
#         h <- sapply(h, paste0, collapse=" ")  
#         h <- gsub("\n", " ", h)
#         h <- gsub("\r", " ", h)
#         df[,x[i]] <- h
#       }
#   return(df)
# }

x <- funcion_html(data)
x <- x %>% filter(!correlativo == '')
write.xlsx(x, 'archivo.xlsx')                                                     
