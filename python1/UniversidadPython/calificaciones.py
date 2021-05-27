nota = int(input('Ingrese su nota del 1 al 10: '))

if nota >= 0 and nota < 6:
    print('Tu nota es: F')
elif nota >= 6 and nota < 7:
    print('Tu nota es: D')
elif nota >= 7 and nota < 8:
    print('Tu nota es: C')
elif nota >=8 and nota <9:
    print('Tu nota es: B')
elif nota >= 9 and nota <=10:
    print('Tu nota es: A')
else:
    print('Valor desconocido')            