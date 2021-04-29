inversion = float(input('Ingrese la cantidad a invertir: '))
int_anual = int(input('Ingrese el interés anual: '))
num_años = int(input('Ingrese los años: '))

for i in range(num_años):
    inversion *= 1 + int_anual / 100
    print('Capital tras' + str(i+1) + ' años: ' + str(round(inversion, 2)))