library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Devolución a Borrador"),
  
  sidebarLayout(
    sidebarPanel(
      
      HTML('<h3>Estatus de Respuesta</h3>'),
      htmlOutput('estatus'),
      
      
      HTML('<h3>Tipo de NO Respondidas</h3>'),
      htmlOutput('estandar'),
      downloadLink("descarga_no_estandar", "Descargar proyectos con comunicaciones no estandar"),
      
      
      HTML('<h3>Evaluados</h3>'),
      htmlOutput('estatus_proyecto'),
      downloadLink("descarga_evaluados", "Descargar proyectos ya evaluados"),
      
      
      HTML('<h3>Respuestas estandar</h3>'),
      htmlOutput(("respuestas_estandar"))
      
    ),
    
    mainPanel(
      htmlOutput("titulo"),
      htmlOutput("comunicacion"),
    )
  )
))