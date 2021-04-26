pan = float(input('Ingrese pan viejo a comprar: '))
precio = 3.49
descuento = 0.6

coste = pan * precio * (1 - descuento)

print("El coste de una barra fresca es " + str(precio) + "€")
print("El descuento sobre una barra no fresca es " + str(descuento * 100) + "%")
print("El coste final a pagar es " + str(round(coste, 2)) + "€")
