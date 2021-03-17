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

my_name <- readline(prompt = "Ingrese su nombre!: ")

valor1 <- readline(prompt="Ingrese el primer valor: ")
valor2 <- readline(prompt="Ingrese segundo valor: ")

valor1  <- as.integer(valor1) 
valor2 <- as.integer(valor2)

op1 <- readline(prompt = "Ingrese el valor aritmetico a ser comparado con las dos variables: ")
op2 <- readline(prompt = "Ingrese el valor aritmetico a ser comparado con las dos variables: ")

print(paste("Hola,", my_name, 
            "el resulado loco de su calculadora es: ", 
            calcular(x = valor1, y = valor2, operacion1 = op1)
            ))

resultado <- calcular(x = valor1, y = valor2, operacion1 = op1)

print(resultado)

regunta_operacion_3 <- readline(prompt="desea hacer alguna operacion con el resultado: ")

if(regunta_operacion_3 == 'si'){
  
  valor2 <- readline(prompt="Ingrese segundo valor: ")
  
  resultado2 <- calcular(x = resultado, y = valor2, operacion1 = op1)
  
}


print(resultado2)

#https://fhernanb.github.io/Manual-de-R/ingresando-datos-a-r.html
