library(shinythemes)
library(shiny)
library(plotly)
library(markdown)

shinyUI(navbarPage("2015 Flight Delays and Cancellations", theme = "United.css",
                   tabPanel(title = "Home",
                            
                            titlePanel('Information Summary'),
                            
                            sidebarLayout(
                              
                              sidebarPanel(
                                # selectInput()
                              ),
                              
                              mainPanel(
                                #plotOutput(),
                                #includeMarkdown(),
                              )
                            )
                            
                            
                   ),
                   
                   tabPanel(title = "Map",
                            
                            sidebarLayout(
                              
                              sidebarPanel(
                                selectInput(inputId = "location",
                                            label = "Choose the variable you want to see:",
                                            choices = c("Airport Location", "Dates"),
                                            selected = "Airport Location")
                              ),
                              
                              mainPanel(
                                plotOutput("map")
                              )
                            )
                            
                   ),
                   
                   tabPanel(title = "Component 3")
))
