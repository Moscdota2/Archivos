nombre = input('Ingrese su nombre: ')
sexo = input('Ingrese su sexo (M o F): ')

if sexo == 'M':
    if nombre.lower() < 'm':
        print('Tu grupo es el A')
    else:
        print('Tu grupo es el B')
else:
    if nombre.lower() > 'n':
        print('Tu grupo es el A')
    else:
        print('Tu grupo es el B')