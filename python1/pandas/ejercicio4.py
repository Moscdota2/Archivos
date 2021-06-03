import pandas as pd

columnas = ('Mes', 'Ventas', 'Gastos')

data = pd.DataFrame([
    ['Enero', 30500, 22000],
    ['Febrero', 35600, 23400],
    ['Marzo', 28300, 18100],
    ['Abril', 33900, 20700]], columns=columnas)

print(data)