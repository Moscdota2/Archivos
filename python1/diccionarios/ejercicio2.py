nombre = input('Ingrese su nombre: ')
edad = input('Ingrese su edad: ')
direccion = input('Ingrese su dirección (Ciudad): ')
telefono = input('Ingrese su número de teléfono: ')

diccionario = {'nombre' : nombre, 'edad' : edad, 'direccion' : direccion, 'telefono': telefono}
print(diccionario['nombre'], 'tiene' , diccionario['edad'], 'años, vive en ' , diccionario['direccion'], 'su teléfono es: ', diccionario['telefono'])