funcion_calculadora <- function(n1, n2, comp){
  if(comp == 'suma'){
    res <- (n1 + n2)
    return(res)
  } 
  if (comp == 'resta'){
    res <- (n1 - n2)
    return(res)
  } 
  if (comp == 'multiplicacion'){
    res <- (n1 * n2)
    return(res)
  } 
  if (comp == 'division'){
    res <- (n1 / n2)
    return(res)
  } 

  return(res)
 
}

calcular <- function(x, y, operacion1,  operacion2 = NA){
  if(!is.na(x) & !is.na(y) & !is.na(operacion1)){
     resultado <- funcion_calculadora(x,y,operacion1)
    if(!is.na(operacion2)){
      resultado <- funcion_calculadora(resultado, nuevo_valor, operacion2)
    }
    resultado
    } else {
    print('ingrese datos correctos')
    resultado <- NA
  }
 return(resultado)
}


calcular(x = 10, y = 10, operacion1 =  'resta', nuevo_valor =  10, operacion2 =  'suma')



