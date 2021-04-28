edad = int(input('Ingrese su edad: '))
ingresos = float(input('Ponga sus ingresos anuales: '))

if edad > 16 and ingresos >= 1000:
    print('Usted es apto para tributar')
else:
    print('Usted no es apto para tributar aún')

