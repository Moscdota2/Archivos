funcion_sql <- function(){
  sqlcomando <- "select obpp_situr_name, code, obpp_name, state_proyect from app
  where state_proyect='Borrador' or state_proyect='En evaluación' or state_proyect='Pre-evaluación';"
  
  conexion <- dbConnect(PostgreSQL(), user = 'postgres', password = '040200', dbname = 'postgres')
  out2 <- dbGetQuery(conexion, sqlcomando)
  desconexion <- dbDisconnect(conexion)

  return(out2)
}
