# left side men
# 
library(shinydashboard)
library( shinyWidgets )
dashboardPage(
  dashboardHeader(title="Car data analysis"),
  dashboardSidebar(            # all ui stuff are developed in server side
    uiOutput("car_brand"),
    uiOutput("car_model"),
    uiOutput("year_range"),
    uiOutput("price_range")),
  dashboardBody(
    uiOutput("car_stats_dashboard"),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    )
    
  )
)