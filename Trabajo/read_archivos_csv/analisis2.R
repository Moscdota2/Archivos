library(dplyr)
library(lubridate)
library(xlsx)
library(readxl)



data <- read_xlsx(input$fileid$datapath)
names(data) <- func_titulo(data)
data <- data %>% filter(!is.na(codigo_de_proyecto))


comparador <- read_xlsx(input$fileid3$datapath)

comparadorjuntos <- comparadorjuntos %>% mutate(Asuntos_origen = Asunto)


comparadorjuntos <- comparadorjuntos %>% 
  mutate(Asunto = trimws(Asunto)) %>% 
  mutate(Asunto = tolower(Asunto)) %>%
  mutate(Asunto = chartr('áéíóú', 'aeiou', Asunto)) %>%
  mutate(Asunto = gsub('[[:punct:]]', ' ', Asunto)) %>%
  mutate(Asunto = gsub('_{2,}', ' ', Asunto)) %>%
  mutate(Asunto = gsub('[[:space:]]{2,}', ' ', Asunto))



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


cond1 <- data$motivo_1 %in% comparadorjuntos$Asunto
cond2 <- data$motivo_2 %in% comparadorjuntos$Asunto | is.na(data$motivo_2)
cond3 <- data$motivo_3 %in% comparadorjuntos$Asunto | is.na(data$motivo_3)
cond4 <- data$motivo_4 %in% comparadorjuntos$Asunto | is.na(data$motivo_4)
cond5 <- data$motivo_5 %in% comparadorjuntos$Asunto | is.na(data$motivo_5)

estandar <- cond1 & cond2 & cond3 & cond4 & cond5

data$estandar <- estandar


remove(cond1, cond2, cond3, cond4, cond5, estandar)


data <- data %>%
  mutate(respondida = if_else(
    is.na(codigo_de_comunicacion_enviada_informacion_atencion_al_ciudadano_),
    'No respondida',
    'Respondida'))


data <- data %>% mutate(codigo_de_proyecto = gsub('[[:cntrl:]]','',codigo_de_proyecto)) %>%
  mutate(codigo_de_proyecto = trimws(codigo_de_proyecto))


resumen_respondida <- data %>% group_by(respondida) %>% tally(name = 'Proyectos')
resumen_estandar <- data %>% filter(respondida == 'No respondida') %>% group_by(estandar) %>% tally(name = 'Proyectos')


data$codigo_valido <- grepl('^CCO-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}', data$codigo_de_proyecto) | grepl('^COM-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{5}', data$codigo_de_proyecto)


data <- data %>% mutate(clave = paste(codigo_de_proyecto, '-',n_))


comparador <- read.csv(input$fileid3$datapath, stringsAsFactors = FALSE)


comparador <- comparador %>% select(code, obpp_situr_code, obpp_name,state )

unique(comparador$state)

proyectos_en_evaluacion <- comparador %>% filter(state %in% 'En evaluación') %>% pull(code)

data <- data %>% mutate(estatus_valido = if_else(codigo_de_proyecto %in% proyectos_en_evaluacion, FALSE,TRUE))

titulo <- func_titulo(comparadorjuntos)
colnames(comparadorjuntos) <- titulo

#18Guardamos para trabajar en la aplicación
#save(comparador, comparadorjuntos , data, resumen_estandar, resumen_respondida, proyectos_en_evaluacion, file = './scriptaction.RData')
