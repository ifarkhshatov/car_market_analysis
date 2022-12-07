# left side menu:
# choose Brand;
# choose model;
# year range;
# show stats:
# price dynamics (histogramm) so far :D
# 

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    includeCSS("www/style.css"),
    # Application title
    titlePanel("Car data analysis"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            # all ui stuff are developed in server side
            uiOutput("car_brand"),
            uiOutput("car_model"),
            uiOutput("year_range"),
        ),

        # Show a plot of the generated distribution
        mainPanel(
           uiOutput("car_stats_dashboard")
        )
    )
))
