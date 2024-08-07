source('/home/analista/Ejercicios R/Tareas Isaias/Ejercicio Gmail 2 Funciones.R')

library(googledrive)
library(lubridate)
library(dplyr)
library(readxl)

googledrive::drive_auth()
googledrive::drive_token() -> acceso
saveRDS(acceso, "acceso_go.rds")



drive_auth(token = readRDS("acceso_go.rds"))

drive_ls(path = "Datasets")

data <- drive_get(path = '')

drive_find(n_max = 2)

drive_download(file = as_id('https://docs.google.com/spreadsheets/d/1oJ4VsZrPWppctt5yaCqoeYAt43Ah_7WhlD7CxuzBg4o/edit#gid=0')
                            , type = 'xlsx', path = "/home/analista/Descargas/BORRADOR ATENCIÓN AL CIUDADANO.xlsx", overwrite = TRUE)

data <- read_xlsx("/home/analista/Descargas/BORRADOR ATENCIÓN AL CIUDADANO.xlsx", sheet = '2021')

names(data) <- func_titulo(data)

names(data)

comparadorjuntos <- read_xlsx('/home/analista/Trabajo/Comparadores.xlsx')

comparadorjuntos <- comparadorjuntos %>% 
  mutate(Asunto = trimws(Asunto)) %>% 
  mutate(Asunto = tolower(Asunto)) %>%
  mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
  mutate(Asunto = gsub('[[:punct:]]', '_', Asunto)) %>%
  mutate(Asunto = gsub('_{2,}', '_', Asunto))


data <- data %>% 
  mutate(motivo_1 = trimws(motivo_1),
         motivo_2 = trimws(motivo_2),
         motivo_3 = trimws(motivo_3),
         motivo_4 = trimws(motivo_4),
         motivo_5 = trimws(motivo_5)) %>% 
  mutate(motivo_1 = tolower(motivo_1),
         motivo_2 = tolower(motivo_2),
         motivo_3 = tolower(motivo_3),
         motivo_4 = tolower(motivo_4),
         motivo_5 = tolower(motivo_5)) %>%
  mutate(motivo_1 = chartr('áéíóú', 'aeiou', motivo_1),
         motivo_2 = chartr('áéíóú', 'aeiou', motivo_2),
         motivo_3 = chartr('áéíóú', 'aeiou', motivo_3),
         motivo_4 = chartr('áéíóú', 'aeiou', motivo_4),
         motivo_5 = chartr('áéíóú', 'aeiou', motivo_5)) %>%
  mutate(motivo_1 = gsub('[[:punct:]]', '_', motivo_1),
         motivo_2 = gsub('[[:punct:]]', '_', motivo_2),
         motivo_3 = gsub('[[:punct:]]', '_', motivo_3),
         motivo_4 = gsub('[[:punct:]]', '_', motivo_4),
         motivo_5 = gsub('[[:punct:]]', '_', motivo_5)) %>%
  mutate(motivo_1 = gsub('_{2,}', '_', motivo_1),
         motivo_2 = gsub('_{2,}', '_', motivo_2),
         motivo_3 = gsub('_{2,}', '_', motivo_3),
         motivo_4 = gsub('_{2,}', '_', motivo_4),
         motivo_5 = gsub('_{2,}', '_', motivo_5))


cond1 <- data$motivo_1 %in% comparadorjuntos$Asunto
cond2 <- data$motivo_2 %in% comparadorjuntos$Asunto | is.na(data$motivo_2)
cond3 <- data$motivo_3 %in% comparadorjuntos$Asunto | is.na(data$motivo_3)
cond4 <- data$motivo_4 %in% comparadorjuntos$Asunto | is.na(data$motivo_4)
cond5 <- data$motivo_5 %in% comparadorjuntos$Asunto | is.na(data$motivo_5)


estandar <- cond1 & cond2 & cond3 & cond4 & cond5

data$estandar <- estandar

remove(cond1, cond2, cond3, cond4, cond5, estandar)
names(data)
#------------------------------------------------------------
data <- data %>%
  mutate(respondida = if_else(
    is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
    'No respondida',
    'Respondida'))
#------------------------------------------------------------

resumen_respondida <- data %>% group_by(respondida) %>% tally(name = 'Proyectos')
resumen_estandar <- data %>% filter(respondida == 'No respondida') %>% group_by(estandar) %>% tally(name = 'Proyectos')



