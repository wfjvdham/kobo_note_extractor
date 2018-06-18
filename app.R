library(shiny)
library(tidyverse)
library(rvest)
library(stringr)
library(readr)

ui <- fluidPage(
  titlePanel("Extract your Kobo Notes"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file_input", "Choose *.annot file to extract your notes from",
                accept = ".annot"),
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
    if (length(rv$notes) > 0) {
      rv$notes
    } else {
      "Cannot extract any notes from the file. Are you sure it is a valid *.annot file?"
    }
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(input$file_input$name, ".notes.txt")
    },
    content = function(con) {
      rv$notes %>%
        write_lines(con)
    }
  )
  
  output$download_button <- renderUI({
    req(input$file_input) 
    if (length(rv$notes) > 0) {
      downloadButton("downloadData", label = "Download Notes", class="btn btn-primary")
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

