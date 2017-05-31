library(shinythemes)
library(shiny)
library(plotly)
library(leaflet)
library(maps)
library(dplyr)
library(markdown)

shinyServer(function(input, output) {
  airport <- read.csv("./data/airports.csv", stringsAsFactors = FALSE)
  airlines <- read.csv("./data/airlines.csv", stringsAsFactors = FALSE)
  flights <- read.csv("./data/flights.csv", stringsAsFactors = FALSE)
  
  #filter out the numbers in the airport columns
  flights <- flights[!(grepl("[[:digit:]]", flights$ORIGIN_AIRPORT) == TRUE), ]
  
    output$map <- renderPlot( {
      map("state", regions= ".", mar = c(.5,.5,.5,.5), namefield = )
      points(x = airport$LONGITUDE, y = airport$LATITUDE, col = "red")
    })
    
    #creates a scatter plot that can be filtered based on date
    output$scatter <- renderPlotly({
      #add leading zeroes to month and day to make the length of the numbers the same and create the date column
      flights$MONTH <- sprintf("%02d", flights$MONTH)
      flights$DAY <- sprintf("%02d", flights$DAY)
      flights$date <- as.Date(paste0("2015-", flights$MONTH, "-", flights$DAY))
      
      dataset <- reactive({
        df <- flights[flights$date >= input$daterange[1] & flights$date <= input$daterange[2], ]
        return (df)
      })
      
      m <- list(l = 100, r = 40, b = 100, t = 50, pad = 0)
      
      scatter <- plot_ly(dataset(), type = "scatter", mode = "markers") %>% 
        add_markers(x = ~ORIGIN_AIRPORT, y = ~DEPARTURE_DELAY, color = ~AIRLINE, hoverinfo = "text",
                    text = ~paste0("Airline: ", AIRLINE, "<br>Origin Airport: ", ORIGIN_AIRPORT, 
                                   "<br>Destination Airport: ", DESTINATION_AIRPORT, "<br>Departure Delayed Time: ", DEPARTURE_DELAY,
                                   "<br>Date: ", date)) %>% 
        layout(title = "Delayed Time of Flights in 2015", xaxis = list(title = "Origin Airport"),
               yaxis = list(title = "Departure Delayed Time (mins)"), margin = m)
    })
})