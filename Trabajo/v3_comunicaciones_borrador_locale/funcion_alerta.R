func_alerta <- function(x){
data_rara <- read.csv(x)
data_rara[data_rara$code == '', 'code'] <- NA
data_rara <- data_rara %>% mutate(code2 = code) %>%  fill(code)

data_rara <- data_rara %>% filter(project_timeline_ids.create_date != '')

data_rara <- data_rara %>% 
  mutate(project_timeline_ids.create_date = ymd_hms(project_timeline_ids.create_date)) %>% 
  mutate(project_timeline_ids.create_date =  date(project_timeline_ids.create_date))

df3 <- data_rara %>% 
  select(code, project_timeline_ids.create_date, project_timeline_ids.descripcion) %>% 
  distinct()

resumen <- df3 %>% 
  group_by(code,project_timeline_ids.descripcion) %>% tally()

resumen_borrador <- resumen %>% 
  filter(project_timeline_ids.descripcion == 'Borrador')

mean(resumen_borrador$n)
hist(resumen_borrador$n)
boxplot(resumen_borrador$n)

cuantil<- quantile(resumen_borrador$n,  probs = seq(0, 1, 0.05))

alerta <- resumen_borrador %>% filter(n >= cuantil['95%'])

return(alerta)

}