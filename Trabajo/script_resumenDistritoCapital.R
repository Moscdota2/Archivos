library(lubridate)
library(dplyr)
library(tidyr)

d1 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/cancInsNOForzConVehiculo.csv')
d2 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/cancInsNOForzSinVehiculoConRubros.csv')
d3 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/cancInsNoForzSinVehiculoSinRubroMC1.csv')
d4 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/cancInsNoForzSinVehiculoSinRubroMC2.csv')
d5 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/cancInsNoForzSinVehiculoSinRubroSinMC.csv')
d6 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/cancInstForzCOC.csv')
d7 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/cancInstForzSOC.csv')
d8 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/co.csv')
d9 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/culcoc.csv')
d10 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/culsoc.csv')
d11 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/otros.csv')
d12 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/aedej.csv')
d13 <- read.csv('Descargas/Telegram Desktop/IRD_v2/ird/bpe.csv')

data <- rbind(d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13) 


resumen_data <- data %>% 
  filter(obpp_estado == 'DISTRITO CAPITAL') %>% 
  mutate(aprobado = if_else((state %in% c('Culminado','En ejecución','A espera de desembolso')) | !is.na(accountability_id.percent), 
                            TRUE, 
                            FALSE)) %>% 
  group_by(obpp_situr_code, obpp_name, aprobado, obpp_estado) %>% 
  summarise(proyectos=n(),average=mean(accountability_id.percent,na.rm = TRUE))

resumen_aprobaciones <- resumen_data %>% select(obpp_situr_code, aprobado, proyectos) %>% spread(aprobado,proyectos, fill = 0) 
resumen_aprobaciones <- resumen_aprobaciones %>% mutate(`FALSE`+`TRUE`)
resumen_average <- resumen_data %>% select(obpp_situr_code, average) %>% filter(!is.na(average))
 names(resumen_aprobaciones) <- c('OBPP', 'Código SITUR', 'No Financiado', 'Financiado', 'Total')
 names(resumen_average) <- c('OBPP', 'Aprobado', 'Código SITUR', 'Average')
resumen <- left_join(resumen_aprobaciones, resumen_average) 

write.csv(resumen, file = 'resumen.csv')
