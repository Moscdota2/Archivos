archivo_xlsx <- function(x){
  
  if(grepl('.xlsx$', x)){
    return(read_xlsx(x, sheet = '2021'))
  } else {return(NULL)}}


archivo_csv <- function(x){
  if(grepl('.csv$', x)){
    return(read.csv(x, stringsAsFactors = F))
  } else {return(NULL)}}





