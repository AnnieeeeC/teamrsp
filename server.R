library(shinythemes)
library(shiny)
library(plotly)
library(maps)
library(dplyr)
library(markdown)

shinyServer(function(input, output) {
  #read data files
  airport <- read.csv("./data/airports.csv", stringsAsFactors = FALSE)
  airlines <- read.csv("./data/airlines.csv", stringsAsFactors = FALSE)
  flights <- read.csv("./data/flights.csv", stringsAsFactors = FALSE)
  
  output$map <- renderPlotly( {
    
    #filter data with necessary info for maps
    airport.mod1 <- select(flights, ORIGIN_AIRPORT, YEAR, MONTH, DAY, AIRLINE, FLIGHT_NUMBER)
    colnames(airport.mod1)[1] <- "IATA_CODE"
    airport.mod2 <- select(flights, DESTINATION_AIRPORT, YEAR, MONTH, DAY, AIRLINE, FLIGHT_NUMBER)
    colnames(airport.mod2)[1] <- "IATA_CODE"
    
    filtered.airport <- left_join(airport.mod1, airport)
    filtered.airport2 <- left_join(airport.mod2, airport)
    
    total <- merge(filtered.airport, filtered.airport2, by="row.names", all.x=TRUE)
    total <-na.omit(total)
    
    #set background of maps
    geo <- list(
      scope = 'north america',
      projection = list(type = 'azimuthal equal area'),
      showland = TRUE,
      landcolor = toRGB("gray95"),
      countrycolor = toRGB("gray80")
    )
    
    #create maps depend on inputID
    if(input$location == "Airport Location") {
      p <- plot_geo(airport, locationmode = 'USA-states') %>%
        add_markers(
          data = airport, x = ~LONGITUDE, y = ~LATITUDE, hoverinfo = "text",
          text = ~paste0("Airport: ", airport$AIRPORT, "<br>IATA_CODE: ", airport$IATA_CODE, "<br>City: ", airport$CITY, 
                         "<br>State: ", airport$STATE)
        ) %>% 
        layout(
          title = '2015 Airport Locations <br>(Hover for airport infomation)',
          geo = geo
        )
      } else if(input$location == "Flights") {
      p <- plot_geo(airport, locationmode = 'USA-states') %>%
        add_markers(
          data = airport, x = ~LONGITUDE, y = ~LATITUDE
        ) %>% 
        add_segments(
          data = total,
          x = ~LONGITUDE.x, xend = ~LONGITUDE.y,
          y = ~LATITUDE.x, yend = ~LATITUDE.y,
          alpha = 0.3, size = I(1), hoverinfo = "text", 
          text = ~paste0("Flight Number: ", total$FLIGHT_NUMBER.x, "<br>From: ", total$AIRPORT.x, ", ", total$CITY.x, "<br>To: ", 
                         total$AIRPORT.y, ", ", total$CITY.y, "<br>Date: ", total$MONTH.x, "/", total$DAY.x, "/", total$YEAR.x)
        ) %>%
        layout(
          title = '2015 Flights <br>(Hover for flight details)',
          geo = geo
        )
      } else if(input$location == "Airlines") {
      p <- plot_geo(airport, locationmode = 'USA-states') %>%
        add_markers(
          data = airport, x = ~LONGITUDE, y = ~LATITUDE
        ) %>% 
        add_segments(
          data = total,
          x = ~LONGITUDE.x, xend = ~LONGITUDE.y,
          y = ~LATITUDE.x, yend = ~LATITUDE.y,
          alpha = 0.3, size = I(1), hoverinfo = "text", text = ~paste0("Airline: ", total$AIRLINE.x), color= ~total$AIRLINE.x
        ) %>%
        layout(
          title = '2015 Flight Airlines <br>(Hover for airlines, <br>Double click legend for individual airline flights',
          geo = geo
        )
      }
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
    
    #creates a pie chart that finds the maximum departure or arrival delay per month
    output$pie <- renderPlotly({
      dataset <- reactive({
        if(input$var == "DEPARTURE_DELAY") {
          flights %>%
            group_by(MONTH) %>%
            slice(which.max(DEPARTURE_DELAY)) %>%
            mutate(max = DEPARTURE_DELAY)
        } else {
          flights %>%
            group_by(MONTH) %>% 
            slice(which.max(ARRIVAL_DELAY)) %>%
            mutate(max = ARRIVAL_DELAY)
        }
      })
      
      pie <- plot_ly(dataset(), labels = ~MONTH, values = ~max, type = 'pie',
                     textposition = 'inside',
                     textinfo = 'label+percent',
                     insidetextfont = list(color = '#FFFFFF '),
                     hoverinfo = 'text',
                     text = ~paste0('Delayed Time: ', max, 'mins <br>Month: ', MONTH, '<br>Airline: ',
                                    AIRLINE, '<br>Origin Airport: ', ORIGIN_AIRPORT,
                                    '<br> Departure Airport: ', DESTINATION_AIRPORT)) %>%
        layout(title = 'Latest Flight Per Month')
    })
})