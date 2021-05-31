materias = ['Matematica', 'Física']
notas = []
for materia in materias:
    nota = input('Ingrese sus nota en esta materia de: ' + materia + '? ')
    notas.append(nota)
for i in range(len(materias)):
    print('En ' + materias[i] + ' has sacado: ' + notas[i])    