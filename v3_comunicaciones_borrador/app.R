library(shiny)
library(shinydashboard)

ui <- fluidPage(#Leo

    titlePanel("Version #3"),
    
    dashboardPage( skin = 'black',
        dashboardHeader(title = "Devolución a Borrador"),
        dashboardSidebar(
            sidebarMenu(
                menuItem("Inicio", tabName = "inicio", icon = icon("th")),
                menuItem("Información", tabName = "info", icon = icon("th")),
                menuItem("Data Borrador", tabName = "borrador"),
                menuItem("Data Códigos SINCO", tabName = "code_sinco"),
                menuItem("Acciones hechas por el programa", tabName = 'pasos')
            ) 
        ),
        dashboardBody(
            tabItems(
                tabItem(tabName = 'inicio',
                        htmlOutput('titulo'),
                        box(solidHeader = F, 
                            width = 12, column(12, align="center", imageOutput('alcaravan_png',height = "200px"))),
                        box(solidHeader = F, 
                            width = 12, column(12, align="center", imageOutput('sinco_png', height = "375px")))
                        ),
                tabItem(
                    tabName = 'info',
                    box(fileInput(inputId = 'fileid', label = "Elija el Archivo de Borrador .Excel"),
                    fileInput(inputId = 'fileid2', label = 'Elija el Archivo CSV de los códigos de las OBPP'),
                    actionButton(inputId = 'bottomid', label = 'Aceptar'))
                ), 
                tabItem(tabName = 'borrador'),
                tabItem('code_sinco'),
                tabItem(tabName = 'pasos',
                        htmlOutput("texto"))
                )
            
        )
    )

)

server <- function(input, output) {#Sai
    
    #Vista de imagen Leo
    output$alcaravan_png <- renderImage({
        list(src = 'WWW/photo_2021-04-12_13-37-57.jpg',
             width = 600)
    })
    
    #Vista de imagen Leo
    output$sinco_png <- renderImage({
        list(src = 'WWW/logo_sinco.png',
             width = 600)
    })
    
    #Vista de HTML Inicio Leo
    output$titulo <- renderUI({
        HTML('<h1>Inicio</h1>')
    })
    
    #Vista HTML Pasos Leo
    output$texto <- renderUI({
        box(HTML('<p>
            1-Utilizamos la función de estandarización para los títulos de la data y los mostramos.<br>
            2-Llamamos otra data con datos "fiables" de códigos <b>OBPP</b> para comparar.<br>
            3-Estadarizamos el cuerpo de los dataframes de comparación y la data descargada.<br>
            4-Estandarizamos el cuerpo de los datos de las filas y columnas del dataframe<br>
            5-Se compara la data descargada de Drive con el comparador, y se le asigna una variable.<br>
            6-Removemos variables para espacio de memoria.<br>
            7-Utilizamos una condicional para decir si el codigo está respondido, o no.<br>
            8-Estandarizamos los saltos de línea, retornos de carro, etc...<br>
            9-Agrupamos los repondidos y los no respondidos.<br>
            10-Buscamos en la data patrones para los códigos.<br>
            11-Mutamos el código de la data.<br>
            12-Utilizamos las datas del proyecto.<br>
            13-Seleccionamos códigos.<br>
            14-Mostrar los códigos sin repetirse.<br>
            15-Flitramos por los Proyectos en Evaluación y limpiamos el código para evitar mostrar códigos repetidos.<br>
            16-Utilizamos una condicional para comparar códigos.<br>
            17-Estandarizamos el título de la data de la comparación.<br>
        </p>'))
    })

}

shinyApp(ui = ui, server = server)
