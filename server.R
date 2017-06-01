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
  flights <- read.csv("./data/flights.csv")
  
  #filter out the numbers in the airport columns
  flights <- flights[!(grepl("[[:digit:]]", flights$ORIGIN_AIRPORT) == TRUE), ]
  
  #creates an interactive map
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
      scope = "north america",
      projection = list(type = "azimuthal equal area"),
      showland = TRUE,
      landcolor = toRGB("gray95"),
      countrycolor = toRGB("gray80")
    )
    
    #creates a map that depends on inputID
    if(input$location == "Airport Location") {
      p <- plot_geo(airport, locationmode = "USA-states") %>%
        add_markers(
          data = airport, x = ~LONGITUDE, y = ~LATITUDE, hoverinfo = "text",
          text = ~paste0("Airport: ", airport$AIRPORT, "<br>IATA_CODE: ", airport$IATA_CODE, "<br>City: ", airport$CITY, 
                         "<br>State: ", airport$STATE)
        ) %>% 
        layout(
          title = "2015 Airport Locations <br>(Hover for airport infomation)",
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
          title = "2015 Flights <br>(Hover for flight details)",
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
          title = "2015 Flight Airlines <br>(Hover for airlines, <br>Double click legend for individual airline flights)",
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
      
      #margins
      m <- list(l = 100, r = 40, b = 100, t = 50, pad = 0)
      
      scatter <- plot_ly(dataset(), type = "scatter", mode = "markers") %>% 
        add_markers(x = ~ORIGIN_AIRPORT, y = ~DEPARTURE_DELAY, color = ~AIRLINE, hoverinfo = "text",
                    text = ~paste0("Airline: ", AIRLINE, "<br>Origin Airport: ", ORIGIN_AIRPORT, 
                                   "<br>Destination Airport: ", DESTINATION_AIRPORT, "<br>Departure Delayed Time: ", DEPARTURE_DELAY,
                                   "<br>Date: ", date)) %>% 
        layout(title = "Delayed Time of Flights in 2015", xaxis = list(title = "Origin Airport"),
               yaxis = list(title = "Departure Delayed Time (mins)"), margin = m)
    })
    
    #creates an interactive bar graph
    output$bar <- renderPlot({
      #creates df for airlines
      avg.airline.data <- group_by(flights, AIRLINE) %>%
        na.omit() %>%
        summarise( MEAN_DEPARTURE_DELAY = round(mean(DEPARTURE_DELAY),0), MEAN_ARRIVAL_DELAY = round(mean(ARRIVAL_DELAY),0))
      
      #creates df for origin airports
      avg.origin.airport.data <- group_by(flights, ORIGIN_AIRPORT) %>%
        na.omit() %>% 
        summarise( MEAN_DEPARTURE_DELAY = round(mean(DEPARTURE_DELAY),0), MEAN_ARRIVAL_DELAY = round(mean(ARRIVAL_DELAY),0))
      
      #creates df for destination airports
      avg.destination.airport.data <- group_by(flights, DESTINATION_AIRPORT) %>%
        na.omit() %>%
        summarise( MEAN_DEPARTURE_DELAY = round(mean(DEPARTURE_DELAY), 0), MEAN_ARRIVAL_DELAY = round(mean(ARRIVAL_DELAY),0))
      
      #changes df depending on input$ydata
      df <- reactive({
        if(input$ydata == "Departure Delay") {
          switch(input$xdata,
                 "Airlines" = avg.airline.data,
                 "Airports" = avg.origin.airport.data)
          
        } else {
          switch(input$xdata,
                 "Airlines" = avg.airline.data,
                 "Airports" = avg.destination.airport.data)
        }
      })
      
      # saves df into a new.data.frame variable. 
      new.data.frame <- df()
      
      #changes what data to use for the yaxis depending on input$ydata
      y.data <- reactive({
        switch(input$ydata,
               "Departure Delay" = new.data.frame$MEAN_DEPARTURE_DELAY,
               "Arrival Delay" = new.data.frame$MEAN_ARRIVAL_DELAY)
      })
      
      #changes what data to use for the xaxis dpending on input$ydata and input$xdata
      x.data <- reactive({
        if(input$ydata == "Departure Delay"){
          switch(input$xdata,
                 "Airlines" = new.data.frame$AIRLINE,
                 "Airports" = new.data.frame$ORIGIN_AIRPORT)
        } else {
          switch(input$xdata,
                 "Airlines" = new.data.frame$AIRLINE,
                 "Airports" = new.data.frame$DESTINATION_AIRPORT)
        }
      })
      
      # changes how the graph is sorted out depending on input$sort
      x.order <- reactive({
        switch(input$sort,
               "Alphabetically" = x.data(),
               "High to Low" = reorder(x.data(), -y.data()),
               "Low to High" = reorder(x.data(), y.data())
        )
      })
      
      #creates the actual bargraph depnding on the different inputs. 
      ggplot(new.data.frame, aes_string(x = x.order(), y = y.data(), width = 0.65, fill = x.data())) +
        labs(x = input$xdata, y = input$ydata) +
        #bunch of modificatiions for the graph
        geom_col()+ theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 12), axis.title.x = element_text(hjust = 0.5), 
                          plot.title = element_text(size = 20)) +
        #creates title base on input$ydata and input$xdata
        ggtitle(paste("Average", input$ydata, "for", input$xdata)) +
        #moves the y axis data
        geom_text(aes(label = y.data()), nudge_y = 5) +
        #creates legend
        scale_fill_discrete(name = paste("Names for", input$xdata),label = x.data()) 
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
      
      pie <- plot_ly(dataset(), labels = ~month.name[MONTH], values = ~max, type = 'pie',
                     textposition = "inside",
                     textinfo = "label+percent",
                     hoverinfo = "text",
                     text = ~paste0("Delayed Time: ", max, " mins <br>Month: ", month.name[MONTH], "<br>Airline: ",
                                    AIRLINE, "<br>Origin Airport: ", ORIGIN_AIRPORT,
                                    "<br> Departure Airport: ", DESTINATION_AIRPORT)) %>%
        layout(title = "Latest Flight Per Month")
    })
})