peso_payaso = 112
peso_muneca = 75

jug_payaso = int(input('Ingrese la cantidad de payasos: '))
jug_muneca = int(input('Ingrese la cantidad de muñecas: '))

total_jug = jug_muneca + jug_payaso
total_jug

total_peso_payaso = peso_payaso * jug_payaso
print('El peso en gramos de los payasos es: ', total_peso_payaso)
total_peso_muneca = peso_muneca * jug_muneca
print('El peso en gramos de las muñecas es: ', total_peso_muneca)

total_peso = total_peso_muneca + total_peso_payaso
total_peso