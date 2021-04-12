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
                )
                )
            
        )
    )

)

server <- function(input, output) {
    
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

}

shinyApp(ui = ui, server = server)
