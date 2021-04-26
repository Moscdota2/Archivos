dinero_banco = float(input('Ingrese dinero a ahorrar: '))]
interes = 0.04
balance1 = dinero_banco * (1 + interes)
balance2 = balance1 * (1 + interes)
balance3 = balance2 * (1 + interes)

print('La inversión en el primer año es: ', round(balance1))
print('La inversión en el primer año es: ', round(balance2))
print('La inversión en el primer año es: ', round(balance3))