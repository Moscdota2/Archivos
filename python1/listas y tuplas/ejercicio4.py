ganadores = []
for i in range(6):
    ganadores.append(int(input('Ingrese 6 numeros ganadores: ')))
ganadores.sort()
print('Los números ganadores son ' + str(ganadores))    