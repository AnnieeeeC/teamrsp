library(shiny)

shinyServer(function(input, output) {
  
  output$text <- renderText({paste0("You are viewing tab \"", input$tabs, "\"")})
  
})