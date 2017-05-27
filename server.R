library(shinythemes)
library(shiny)
library(plotly)
library(leaflet)
library(maps)
library(dplyr)
library(markdown)



shinyServer(function(input, output) {
  
  airport <- read.csv("data/airports.csv", stringsAsFactors = FALSE)
  airlines <- read.csv("data/airlines.csv", stringsAsFactors = FALSE)
  flights <- read.csv("data/flights.csv", stringsAsFactors = FALSE)
  

    output$map <- renderPlot( {
      map("state", regions= ".", mar = c(.5,.5,.5,.5), namefield = )
      points(x = airport$LONGITUDE, y = airport$LATITUDE, col = "red")
    })
})