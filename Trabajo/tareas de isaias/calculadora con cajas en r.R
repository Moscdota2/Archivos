library(utils)
library(svDialogs)
library(rstudioapi)
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
      resultado <- funcion_calculadora(resultado, y, operacion2)
    }
    resultado
  } else {
    showDialog("Calculadora", message = 'Ingrese datos correctos')
    resultado <- NA
  }
  return(resultado)
}

valor1 <- showPrompt(title = "Calculadora", message="Ingrese el primer valor: ") 
valor2 <- showPrompt(title = "Calculadora", message="Ingrese el segundo valor: ")

valor1  <- as.double(valor1) # convert character into double
valor2  <- as.double(valor2)

tryCatch({

op1 <- showPrompt(title = "Calculadora", message = "Ingrese el valor aritmetico a ser comparado con las dos variables: ")
resultado <- calcular(x = valor1, y = valor2, operacion1 = op1)

showDialog("Calculadora", message="El resultado es:", resultado )
print(resultado)

if(!is.infinite(resultado))
  pregunta_operacion_3 <-  showPrompt(title = "Calculadora", message= "Desea hacer alguna operacion con el resultado: ")

if(pregunta_operacion_3 == 'si'){
  valor3 <- showPrompt(title = "Calculadora", message="Ingrese el otro valor: ")
  valor3 <- as.double(valor3)
  op2 <- showPrompt(title = "Calculadora", message= "Ingrese el valor aritmetico a ser comparado con las dos variables: ")
  resultado2 <- calcular(x = resultado, y = valor3, operacion1 = op2)
  
  if(is.infinite(resultado2)){
    showDialog("Calculadora", message = "No se puede dividir entre cero")
  }else{
    showDialog("Calculadora", message = "El resultado es:", resultado2 )
  }
}

print(resultado2)

},
  error = function(err){
    if(valor2 == 0 && op1 == 'division'){
      showDialog("Calculadora", message = "No se puede dividir entre cero")
  }
      
},
  finally = {
    showDialog("Calculadora", message = "Calculadora hecha en R para practicar programacion en r")
    remove(op1, op2, pregunta_operacion_3, resultado, resultado2, valor1, valor2, valor3)
  }
)