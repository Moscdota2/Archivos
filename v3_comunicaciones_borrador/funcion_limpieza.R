#Estandarizamos los títulos de las columnas del dataframe
func_titulo <- function(df){
  
  titulo <- colnames(df)
  minuscula <- tolower(titulo)
  c1 <- trimws(minuscula)
  c2 <- chartr('áéíóú', 'aeiou', c1)
  c3 <- gsub('[[:space:]]', '_', c2)
  ccf <- gsub('[[:punct:]]', '_', c3)
  ccf <- gsub('_{2,}', '_', ccf)

   
  return(ccf)
  
}

#Estandarizamos el cuerpo de los datos de las filas y columnas del dataframe
func_limpieza <- function(data){

names(data)<- func_titulo(data)

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

return(data)
}

load('comparadorjuntos.RData')

#if(file_test('-f', 'caches.RData')){
 # load('caches.RData')
#}

