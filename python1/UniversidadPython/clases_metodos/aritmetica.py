class Aritmetica:
    """
    Clase para practicar peggo
    """

    def __init__(self, operandoA, operandoB):
        self.operandoA = operandoA
        self.operandoB= operandoB

    def sumar(self):
        return self.operandoA + self.operandoB

    def restar(self):
        return self.operandoA - self.operandoB

    def mul(self):
        return self.operandoA * self.operandoB

    def div(self):
        return self.operandoA / self.operandoB

aritmetica1 = Aritmetica(5,3)
print(aritmetica1.sumar())
print(aritmetica1.restar())
print(aritmetica1.mul())
print(aritmetica1.div())