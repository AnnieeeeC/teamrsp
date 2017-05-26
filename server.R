library(shinythemes)
library(shiny)
library(plotly)
library(maps)
library(markdown)

shinyServer(function(input, output) {
  
  output$map <- renderPlot( {
    
    map("state")
    
  } )
  
})