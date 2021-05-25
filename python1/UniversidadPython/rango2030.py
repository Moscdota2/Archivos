edad = int(input('Introduce tu edad: '))

veintes = edad >= 20 and edad < 30
print(veintes)

treintas = edad >= 30 and edad < 40
print(treintas)

if  veintes or treintas:
    print('Dentro del Rango de edad de veintes y treintas')
else:
    print('Se encuentra fuera del rango xd')    

