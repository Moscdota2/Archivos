#Llamamos a las librerías que vamos a usar.
library(googledrive)
library(lubridate)
library(dplyr)
library(readxl)


func_titulo <- function(df){
  
  titulo <- colnames(df)
  minuscula <- tolower(titulo)
  c1 <- trimws(minuscula)
  c2 <- chartr('áéíóú', 'aeiou', c1)
  c3 <- gsub('[[:space:]]', '_', c2)
  ccf <- gsub('[[:punct:]]', '_', c3)
  ccf <- gsub('_{2,}', '_', ccf)
  
  colnames(df) <- ccf  
  return(ccf)
  
}

#Utilizamos la funciones de Google Drive para descargar la data.
#googledrive::drive_auth()
#googledrive::drive_token() -> acceso
#saveRDS(acceso, "acceso_go.rds")
#drive_auth(token = readRDS("acceso_go.rds"))
#data <- drive_get(path = '')
#drive_find(n_max = 2)
#drive_download(file = as_id('https://docs.google.com/spreadsheets/d/1oJ4VsZrPWppctt5yaCqoeYAt43Ah_7WhlD7CxuzBg4o/edit#gid=0')
#               , type = 'xlsx', path = "datas/BORRADOR_ATENCION_AL_CIUDADANO", overwrite = TRUE)

#Leemos el dataframe que descargamos.
data <- read_xlsx("./datas/BORRADOR ATENCIÓN AL CIUDADANO.xlsx", sheet = '2021')

#Utilizamos la función de estandarización para los títulos de la data y los mostramos.
names(data) <- func_titulo(data)

data <- data %>% filter(!is.na(codigo_proyecto))

#Llamamos otra data con datos "fiables" de códigos obpp para comparar.
comparadorjuntos <- read_xlsx('./datas/Comparadores.xlsx')

comparadorjuntos <- comparadorjuntos %>% mutate(Asuntos_origen = Asunto)

#Estadarizamos el cuerpo de los dataframes de comparación y la data descargada.
comparadorjuntos <- comparadorjuntos %>% 
  mutate(Asunto = trimws(Asunto)) %>% 
  mutate(Asunto = tolower(Asunto)) %>%
  mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
  mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
  mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
  mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))

#comparadorjuntos <- comparadorjuntos %>% 
#  mutate(información = trimws(información)) %>% 
#  mutate(información = tolower(información)) %>%
#  mutate(información = chartr('áéíóú', 'aeiou', información)) %>%
#  mutate(información = gsub('[[:punct:]]', ' ', información)) %>%
#  mutate(información = gsub('_{2,}', ' ', información))

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
  mutate(motivo_1 = gsub('[[:punct:]]', ' ', motivo_1),
         motivo_2 = gsub('[[:punct:]]', ' ', motivo_2),
         motivo_3 = gsub('[[:punct:]]', ' ', motivo_3),
         motivo_4 = gsub('[[:punct:]]', ' ', motivo_4),
         motivo_5 = gsub('[[:punct:]]', ' ', motivo_5)) %>%
  mutate(motivo_1 = gsub('[[:space:]]{2,}', ' ', motivo_1),
         motivo_2 = gsub('[[:space:]]{2,}', ' ', motivo_2),
         motivo_3 = gsub('[[:space:]]{2,}', ' ', motivo_3),
         motivo_4 = gsub('[[:space:]]{2,}', ' ', motivo_4),
         motivo_5 = gsub('[[:space:]]{2,}', ' ', motivo_5)) %>% 
  mutate(motivo_1 = gsub('_{2,}', ' ', motivo_1),
         motivo_2 = gsub('_{2,}', ' ', motivo_2),
         motivo_3 = gsub('_{2,}', ' ', motivo_3),
         motivo_4 = gsub('_{2,}', ' ', motivo_4),
         motivo_5 = gsub('_{2,}', ' ', motivo_5))

#Se compara la data descargada de Drive con el comparador, y se le asigna una variable.
cond1 <- data$motivo_1 %in% comparadorjuntos$Asunto
cond2 <- data$motivo_2 %in% comparadorjuntos$Asunto | is.na(data$motivo_2)
cond3 <- data$motivo_3 %in% comparadorjuntos$Asunto | is.na(data$motivo_3)
cond4 <- data$motivo_4 %in% comparadorjuntos$Asunto | is.na(data$motivo_4)
cond5 <- data$motivo_5 %in% comparadorjuntos$Asunto | is.na(data$motivo_5)

estandar <- cond1 & cond2 & cond3 & cond4 & cond5

data$estandar <- estandar

#Removemos variables para espacio de memoria.
remove(cond1, cond2, cond3, cond4, cond5, estandar)

#Utilizamos una condicional para decir si el codigo está respondido, o no.
data <- data %>%
  mutate(respondida = if_else(
    is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
    'No respondida',
    'Respondida'))

#Estandarizamos los saltos de línea, retornos de carro, etc...
data <- data %>% mutate(codigo_proyecto = gsub('[[:cntrl:]]','',codigo_proyecto)) %>%
  mutate(codigo_proyecto = trimws(codigo_proyecto))

#Agrupamos los repondidos y los no respondimos. 
resumen_respondida <- data %>% group_by(respondida) %>% tally(name = 'Proyectos')
resumen_estandar <- data %>% filter(respondida == 'No respondida') %>% group_by(estandar) %>% tally(name = 'Proyectos')

#Buscamos en la data patrones para los códigos. 
data$codigo_valido <- grepl('^CCO-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}', data$codigo_proyecto) | grepl('^COM-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}', data$codigo_proyecto)

#Mutamos el código de la data.
data <- data %>% mutate(clave = paste(codigo_proyecto, '-',n_))

#Utilizamos datas del proyecto.
comparador <- read.csv('./datas/sinco.project.csv', stringsAsFactors = FALSE)

#Seleccionamos códigos.
comparador <- comparador %>% select(code, obpp_situr_code, obpp_name,state )

#Mostrar los códigos sin repetirse.
unique(comparador$state)

#Flitramos por los Proyectos en Evaluación y limpiamos el código para evitar mostrar códigos repetidos.
proyectos_en_evaluacion <- comparador %>% filter(state %in% 'En evaluación') %>% pull(code)

#Utilizamos una condicional para comparar códigos.
data <- data %>% mutate(estatus_valido = if_else(codigo_proyecto %in% proyectos_en_evaluacion, FALSE,TRUE))

#Estandarizamos el título de el data de la comparación.
titulo <- func_titulo(comparadorjuntos)
colnames(comparadorjuntos) <- titulo

save(comparador, comparadorjuntos , data, resumen_estandar, resumen_respondida, proyectos_en_evaluacion, file = './datas.RData')
