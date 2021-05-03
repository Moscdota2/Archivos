library(RPostgreSQL)
library(DBI)

sqlcomando <- 'select * from app;'
conexion <- dbConnect(PostgreSQL(), user = 'postgres', password = '040200', dbname = 'postgres')
data <- dbGetQuery(conexion, sqlcomando)

desconexion <- dbDisconnect(conexion)