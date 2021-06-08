import pandas as pd

data = pd.read_csv('/home/analista/Escritorio/emisiones-2016.csv')
data2 = pd.read_csv('/home/analista/Escritorio/emisiones-2017.csv')
data3 = pd.read_csv('/home/analista/Escritorio/emisiones-2018.csv')
data4 = pd.read_csv('/home/analista/Escritorio/emisiones-2019.csv')

datatotal = pd.concat([data, data2, data3, data4])

columnas = ['ESTACION', 'MAGNITUD', 'ANO', 'MES']
columnas.extend([col for col in data if col.startswith('D')])
emisiones = data[columnas]
emisiones