num = int(input('Ingrese un número: '))

for i in range(num):
    for j in range(i+1):
        print('*', end='')
    print('')    