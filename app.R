library(shiny)
library(tidyverse)
library(rvest)
library(stringr)
library(readr)

ui <- fluidPage(
  titlePanel("Extract your Kobo Notes"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file_input", "Choose *.annot File to extract your notes from",
                accept = c("text/xml")),
      uiOutput("download_button"),
      a("Maracuya IT", href="http://maracuya-it.com/")
    ),
    mainPanel(
      tableOutput("contents")
    )
  )
)

server <- function(input, output) {
  
  rv <- reactiveValues(notes = NULL)

  output$contents <- renderTable({
    
    req(input$file_input)
    
    tryCatch(
      {
        print(input$file_input)
        rv$notes <- input$file_input$datapath %>%
          read_html() %>%
          html_nodes("fragment") %>%
          html_text() %>%
          str_trim()
      },
      error = function(e) {
        stop(safeError(e))
      }
    )
    rv$notes
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(input$file_input$name, "_notes.txt")
    },
    content = function(con) {
      rv$notes %>%
        write_lines(con)
    }
  )
  
  output$download_button <- renderUI({
    req(input$file_input) 
    downloadButton("downloadData", label = "Download Notes", class="btn btn-primary")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

