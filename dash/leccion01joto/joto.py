import dash
import dash_core_components as dcc
import dash_html_components as html 

import plotly.express as px
import pandas as pd

css = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=css)

data = pd.DataFrame({
    'Analistas': ['Ricardo', 'Rosana', 'Sailek', 'Isaias Joto', 'Leopordo'],
    'Edades': [34, 29, 21, 19, 21],
    'Ciudad de Origen': ['Barquisimeto', 'Cagua', 'Barinas', 'San Juan de los Morros', 'Caracas']
})

grafico = px.bar(data, x='Analistas', y='Edades', color='Ciudad de Origen')

app.layout = html.Div(children=[

    html.H1('Hola Joto'),


    html.Div('''
        Aplicacion de prueba para ver graficos (isaias joto)
    '''),

    dcc.Graph(
        id='idgrafico',
        figure=grafico
    )

])

if __name__ == '__main__':
    app.run_server(debug=True)