funcion_calculadora <- function(n1, n2, comp){
  if(comp == 'suma')
    res <- (n1 + n2)
  
  if (comp == 'resta')
    res <- (n1 - n2)
  
  if (comp == 'multiplicacion')
    res <- (n1 * n2)
  
  if (comp == 'division')
    res <- (n1 / n2)

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

valor1 <- readline(prompt="Ingrese el primer valor: ")
valor2 <- readline(prompt="Ingrese segundo valor: ")

tryCatch({

valor1  <- as.double(valor1) 
valor2 <- as.double(valor2)

op1 <- readline(prompt = "Ingrese el valor aritmetico a ser comparado con las dos variables: ")

resultado <- calcular(x = valor1, y = valor2, operacion1 = op1)

print(resultado)

if(!is.infinite(resultado))
  pregunta_operacion_3 <- readline(prompt="Desea hacer alguna operacion con el resultado: ")


if(pregunta_operacion_3 == 'si'){
  
  valor3 <- readline(prompt="Ingrese el otro valor: ")
  
  valor3 <- as.double(valor3)
  
  op2 <- readline(prompt = "Ingrese el valor aritmetico a ser comparado con las dos variables: ")
  
  resultado2 <- calcular(x = resultado, y = valor3, operacion1 = op2)
  
  if(is.infinite(resultado2)){
    print("No se puede dividir entre cero")
  }else{
    print(resultado2)
    }
}

  
},
  error = function(err){
    if(valor2 == 0 && op1 == 'division'){
      readline(prompt = "No se puede dividir entre cero")
    }
},
  finally = {
    readline(prompt = "Calculadora hecha en R para practicar programacion en r")
    remove(op1, op2, pregunta_operacion_3, resultado, resultado2, valor1, valor2, valor3)
 }
)