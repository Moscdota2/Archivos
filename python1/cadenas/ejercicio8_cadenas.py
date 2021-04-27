dinero = input('Ingrese los euros: ')
print(dinero[:dinero.find('.')], 'euros y', dinero[dinero.find('.')+1:], 'céntimos')