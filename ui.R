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
                                # selectInput()
                              ),
                              
                              mainPanel(
                                plotOutput("map")
                                #includeMarkdown(),
                              )
                            )
                            
                            ),
                   
                   tabPanel(title = "Component 3")
))