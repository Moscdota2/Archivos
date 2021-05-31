diccionario = {'Euro':'€', 'Dolar':'$', 'Yen':'¥'}
pregunta = input('Ingrese la divisa a consultar: ')
if pregunta.title() in diccionario:
    print('La divisa es ' + diccionario[pregunta.title()])
else:
    print('No se encuentra la divisa')    