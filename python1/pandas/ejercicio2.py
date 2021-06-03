import pandas as pd

def func(*args):    
    
    t = None
while t != 2:

    print('1. Agregar nota')
    print('2. Salir')
    t = int(input('Ingrese su opcion (1-2) '))
    
    if t == 1: 
        cant_nota = int(input('Cuantas notas desea agregar'))
        list_notas = []
        
        for i in range(cant_nota):
            index_nota = i + 1
            nota = int(input(f'[{index_nota}] Ingrese nota: '))
            list_notas.append(nota)
            
        resultado = notas1(list_notas)
        
        print('Notas Cargadas\n\n')
    elif t == 2:
        break
    else:
        t = None
    
# Este script vale verga