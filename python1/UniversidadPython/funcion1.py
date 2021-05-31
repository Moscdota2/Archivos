# def suma(a,b):
#     print(a+b)

# suma(1, 2)


#Definición de la función para sumar valores
def sumar_valores(*args):
    resultado = 0
    for valor in args:
        resultado += valor
    return resultado

#LLamada de la función
print(sumar_valores(3,5,9))