library(shiny)
library(shinydashboard)

ui <- fluidPage(#Leo

    titlePanel("Version #3"),
    
    dashboardPage( skin = 'black',
        dashboardHeader(title = "Devolución a Borrador"),
        dashboardSidebar(
            sidebarMenu(
                menuItem("Información", tabName = "info", icon = icon("th")),
                menuItem("Widgets", tabName = "widgets", icon = icon("th"))
            ) 
        ),
        dashboardBody(
            tabItems(
                tabItem(tabName = 'info',
                        box(solidHeader = F, 
                            width = 12, column(12, align="center", imageOutput('alcaravan_png')),
                            fileInput(inputId = 'fileid', label = "Elija el Archivo de Borrador .Excel"),
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
             width = 725,
             heigth = 250)
    })

}

shinyApp(ui = ui, server = server)
