library(dplyr)

data_1 <- read.csv("Ejercicios R/Tareas Isaias/2_oct.2020-20210224T174028Z-001/2_oct.2020/data_1.csv", stringsAsFactors = F)
data_2 <- read.csv("Ejercicios R/Tareas Isaias/2_oct.2020-20210224T174028Z-001/2_oct.2020/data_2.csv", stringsAsFactors = F)
data_3 <- read.csv("Ejercicios R/Tareas Isaias/2_oct.2020-20210224T174028Z-001/2_oct.2020/sinco.project.csv", stringsAsFactors = F)

funcion_resumen <- function(df, x){
  x <- df %>%
    group_by_(x)%>%
    tally()%>%
    mutate(pront = round(prop.table(n)*100,2))%>%
    return(x)
}
funcion_resumen(data_1, 'municipality_name')
