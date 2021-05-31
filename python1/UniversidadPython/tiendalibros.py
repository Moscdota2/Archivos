nombre = input('Ingresa el nombre del libro: ')
id = int(input('ingresa el id del libro: '))
precio = float(input('Ingresa el precio con comillas: '))
envio = bool(input('El envio es gratuito: (True/False)'))

print(f'''Nombre {nombre}
id {id}
Precio {precio}
Envio gratis?: {envio}''')