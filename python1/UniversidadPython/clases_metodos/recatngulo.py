class Rectangulo:
    def __init__(self, base, altura):
        self.base = base
        self.altura = altura

    def area(self):
        return  self.base * self.altura

base = int(input('Ingresa la base: '))
altura = int(input('Ingresa la altura: '))

respuesta = Rectangulo(base, altura)
print('El área del rectangulo es:', respuesta.area())