import pandas as pd

titanic = pd.read_csv('/home/analista/Escritorio/titanic.csv')
print(titanic.info())

print('Dimensiones:', titanic.shape)
print('Número de elemntos:', titanic.size)
print('Nombres de columnas:', titanic.columns)
print('Nombres de filas:', titanic.index)
print('Tipos de datos:\n', titanic.dtypes)
print('Primeras 10 filas:\n', titanic.head(10))
print('Últimas 10 filas:\n', titanic.tail(10))

print(titanic.loc[148])
print(titanic.iloc[range(0,titanic.shape[0],2)])