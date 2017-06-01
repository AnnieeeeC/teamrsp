library(shinythemes)
library(shiny)
library(plotly)
library(markdown)

shinyUI(navbarPage("2015 Flight Delays and Cancellations", 
                   
                   theme = shinythemes::shinytheme("united"),
                   
                   tabPanel(title = "Home",
                            
                            titlePanel('Information Summary'),
                            
                            includeMarkdown("./texts/Home.md")
                            
                            
                   ),
                   
                   tabPanel(title = "Map",
                            
                            sidebarLayout(
                              
                              sidebarPanel(
                                selectInput(inputId = "location",
                                            label = "Choose the variable you want to see:",
                                            choices = c("Airport Location", "Flights", "Airlines"),
                                            selected = "Airport Location")
                              ),
                              
                              mainPanel(
                                plotlyOutput("map"),
                                includeMarkdown("./texts/MapDescription.md")
                              )
                            )
                            
                   ),
                   
                   tabPanel(title = "Report",
                            
                            titlePanel("Find Delayed Time of Flight Based on Date"),
                            
                            sidebarPanel(
                              dateRangeInput("daterange", label = h3("Date Range"), min = "2015-01-01", max = "2015-12-31",
                                             start = "2015-01-01", end = "2015-12-31")
                            ),
                            
                            mainPanel(
                              plotlyOutput("scatter"),
                              includeMarkdown("./texts/DateScatterPlotDescription.md"),
                              br(),
                              br()
                            ),
                            
                            titlePanel("Find Maximum Delayed Time Per Month"),
                            
                            sidebarPanel(
                              selectInput("var", label = h3("Airline Delay"), choices = list("Departure Delay" = "DEPARTURE_DELAY",
                                                                                             "Arrival Delay" = "ARRIVAL_DELAY"))
                            ),
                            
                            mainPanel(
                              plotlyOutput("pie"),
                              includeMarkdown("./texts/PieChartDescription.md"),
                              br(),
                              br()
                            ),
                            
                            titlePanel("Average Departure and Arrival Delay Time of Airports and Airlines"),

                            #Creates the side bar panels. 
                            sidebarPanel(
                              selectInput("ydata", "Departure or Arrival Delay",
                                          choices = c("Departure Delay", "Arrival Delay")),
                              selectInput("xdata", "Airlines or Airports",
                                          choices = list("Airlines", "Airports")),
                              selectInput("sort", "Sort Data",
                                          choices = c("Alphabetically", "High to Low", "Low to High"))
                            ),
                            
                            mainPanel(
                              plotOutput('bar'),
                              includeMarkdown("./texts/bargraphsum.md")
                            )
                              )
                            )
                   )         

    

