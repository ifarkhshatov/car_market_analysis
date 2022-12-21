
library(shinydashboard)
library( shinyWidgets )
dashboardPage(
  dashboardHeader(title="Car data analysis"),
  dashboardSidebar(            # all ui stuff are developed in server side
    uiOutput("empty_br"),
    uiOutput("car_brand"),
    uiOutput("car_model"),
    uiOutput("year_range"),
    uiOutput("price_range"),
    uiOutput("odo_range"),
    uiOutput("reset")),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "./custom.css"),
      tags$script(src = "./index.js"),
      tags$script(src = "./chart.js"),
      tags$script(src = "./chart-js/bar.js")
    ), 
    uiOutput("car_chart1"),
    uiOutput("car_chart2"),
    uiOutput("car_chart3"),
    uiOutput("car_chart4"),
    uiOutput("car_chart5"),
  )
)