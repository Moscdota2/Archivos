import pandas as pd

data = pd.read_csv('/home/analista/Escritorio/cotizacion.csv')



def resumen_cotizaciones(fichero):
    df = pd.read_csv(fichero, sep=';', decimal=',', thousands='.', index_col=0)
    return pd.DataFrame([df.min(), df.max(), df.mean()], index=['Mínimo', 'Máximo', 'Media'])

print(resumen_cotizaciones('/home/analista/Escritorio/cotizacion.csv'))
