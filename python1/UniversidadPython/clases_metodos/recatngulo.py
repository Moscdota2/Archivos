class Rectangulo:
    def __init__(self, base, altura):
        self.base = base
        self.altura = altura

    def area(self):
        return  self.base * self.altura

saberarea = Rectangulo(4,5)
print(saberarea.area())