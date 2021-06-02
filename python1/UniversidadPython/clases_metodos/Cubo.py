class Cubo:

    def __init__ (self, alto, ancho, profundidad):
        self.alto = alto
        self.ancho = ancho
        self.profundidad = profundidad

    def res(self):
        return self.alto * self.ancho * self.profundidad

alto = int(input('Ingresa el alto:'))
ancho  = int(input('Ingresa el ancho: '))
profundidad = int(input('Ingresa la profundidad: '))

respuesta = Cubo(alto, ancho, profundidad)
print('El área de un cubo es: ', respuesta.res())