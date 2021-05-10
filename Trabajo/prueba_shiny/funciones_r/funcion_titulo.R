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


