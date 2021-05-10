library(dplyr)
library(ggplot2)

data_1 <- read.csv('Ejercicios R/Tareas Isaias/2_oct.2020-20210224T174028Z-001/2_oct.2020/data_1.csv')
data_2 <- read.csv('Ejercicios R/Tareas Isaias/2_oct.2020-20210224T174028Z-001/2_oct.2020/data_2.csv')
data_3 <- read.csv('Ejercicios R/Tareas Isaias/2_oct.2020-20210224T174028Z-001/2_oct.2020/sinco.project.csv')

source('Ejercicios R/Tareas Isaias/ejercicio_resumen_variables:R.R')

grafico <- funcion_resumen(data_1, 'municipality_name')
grafico

barplot(grafico$n, grafico$pront, names.arg = grafico$municipality_name)

ggplot(grafico, aes(x = n, y = pront)) + geom_col(width = 5)

