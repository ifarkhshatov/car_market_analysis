
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  

  
  #BRAND SELECTOR
  output$car_brand <- renderUI({
    # use names() to show only name not content of select input
    selectInput("car_brand",
                label = h4("Select Brand:"),
                choices = c("All", unique(total_data_parsed$brand)) )
    })

  
  
  # #MODEL SELECTOR
  output$car_model <- renderUI({
    # waiting until first one is generated
    req(input$car_brand)

    if (input$car_brand == "All") {
      choices = "All"
    } else {
      choices = c("All", unique(total_data_parsed$Modelis[total_data_parsed$brand %in% input$car_brand]))
    }
    
    selectInput("car_model",
                label = h4("Select Model:"),
                choices = choices) #multiple = TRUE can used for multiple selection
  })

  # observe(print(input$car_brand))
  # observe(print(input$car_model))
  #YEAR RANGE SLIDER
  output$year_range <- renderUI({
    req(input$car_brand)
    if (input$car_brand != "All") {
      min_year <- min(as.integer(total_data_parsed$Gads[total_data_parsed$brand %in% input$car_brand]))
      max_year <- max(as.integer(total_data_parsed$Gads[total_data_parsed$brand %in% input$car_brand]))
    } else {
      min_year <- min(as.integer(total_data_parsed$Gads))
      max_year <- max(as.integer(total_data_parsed$Gads))
    }
    sliderInput(
      "year_range",
      h4("Select year range:"),
      min = min_year - 1,
      max = max_year + 1,
      value = c(min_year, max_year),
      sep = "",
      step = 1
    )
  })
  
  
  # reactive event e.g. parse data to html to make it workable with chart.js
  dataChartJS_scatter <- eventReactive({
    # any changes in input will adjust table
    input$year_range
    input$car_brand
    input$car_model
  }, {
    # it is required only brand car to do initial dash statistics
    req(input$car_brand)
    req(input$car_model)
    req(input$year_range)
    
    if (input$car_brand == "All") {
      # creat heat map
      
      fun_color_range <- colorRampPalette(c("green", "red"))
      color <- data.frame( 
        odo = seq(min(total_data_parsed$Nobrauk., na.rm = TRUE),
                  max(total_data_parsed$Nobrauk., na.rm = TRUE), by = 100000)) 
      color$color <- fun_color_range(nrow(color))
      
      
      df <- total_data_parsed %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        select(odo = `Nobrauk.`, year = Gads, price = Cena) %>%
        mutate(color =  color$color[findInterval(odo, color$odo)])

    } else {
      models <-
        ifelse(input$car_model == "All",
               unique(total_data_parsed$Modelis),
               input$car_model)
      df <- total_data_parsed  %>%
        # brand
        filter(brand %in%  input$car_brand) %>%
        # model
        filter(Modelis %in% models) %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2]))
    }

    
      df <- jsonlite::toJSON(df)
    })
  
  # sending json object of filtered countries data 
  
  observe(session$sendCustomMessage(type = "dataChartJS_scatter", message = dataChartJS_scatter()))
  
  # to log out reactive table use observer()
  # observe(print(dataChartJS_scatter()))
  #dashboard
  
  output$car_stats_dashboard <-
    renderUI(includeHTML('www/index.html'))
  
})
