funcion_calculadora <- function(n1, n2, n3){
  if(n3 == 'suma'){
    suma <- (n1 + n2)
    return(suma)
  } 
  if (n3 == 'resta'){
    resta <- (n1 - n2)
    return(resta)
  } 
  if (n3 == 'multiplicacion'){
    multiplicacion <- (n1 * n2)
    return(multiplicacion)
  } 
  if (n3 == 'division'){
    division <- (n1 / n2)
    return(division)
  } 
 return(n3)
}
funcion_calculadora(55,2, 'division')


