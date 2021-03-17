winDialog(type="ok", message="¿Usted quiere BORRAR el archivo?")
winDialog(type="yesno", message="¿Usted quiere BORRAR el archivo?")
library(utils)
library(svDialogs) 
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
    print('ingrese datos correctos')
    resultado <- NA
  }
  return(resultado)
}

valor1 <- dlgInput(message="Ingrese su nombre: ")
valor2 <- dlgInput(message="Ingrese su edad en años: ")

valor1  <- as.integer(my_age) # convert character into integer
valor2  <- as.integer(my_age)

op1 <- dlgInput(message = "Ingrese el valor aritmetico a ser comparado con las dos variables: ")

resultado <- calcular(x = valor1, y = valor2, operacion1 = op1)

winDialog(type="ok", message="El resultado es:", resultado )
print(resultado)

pregunta_operacion_3 <- readline(prompt="Desea hacer alguna operacion con el resultado: ")

if(pregunta_operacion_3 == 'si'){
  valor3 <- readline(prompt="Ingrese el otro valor: ")
  op2 <- readline(prompt = "Ingrese el valor aritmetico a ser comparado con las dos variables: ")
  
  resultado2 <- calcular(x = resultado, y = valor2, operacion1 = op2)
}

print(resultado2)

## show dialog boxes en r