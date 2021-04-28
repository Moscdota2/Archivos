renta = float(input('Ingrese su renta: '))

if renta <= 10000:
    print('Le toca el 5%')
elif renta < 20000:
        print('Le toca el 15%')
elif renta < 35000:
    print('Le toca 20%')
elif renta < 60000:
    print('Le toca 30%')
else:
    print('Le toca 45%')

