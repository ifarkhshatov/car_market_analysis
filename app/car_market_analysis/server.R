



options(dplyr.summarise.inform = FALSE)
options(scipen = 999)

library(shiny)
library(shinydashboard)
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  #BRAND SELECTOR
  output$car_brand <- renderUI({
    # use names() to show only name not content of select input
    selectInput(
      "car_brand",
      label = h4("Select Brand:"),
      choices = c("All", unique(total_data_parsed$brand))
    )
  })
  
  
  
  # #MODEL SELECTOR
  output$car_model <- renderUI({
    # waiting until first one is generated
    req(input$car_brand)
    input$car_brand
    
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
    input$car_brand
    if (input$car_brand != "All") {
      min_year <-
        min(as.integer(total_data_parsed$Gads[total_data_parsed$brand %in% input$car_brand]))
      max_year <-
        max(as.integer(total_data_parsed$Gads[total_data_parsed$brand %in% input$car_brand]))
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
  
  #Price range
  output$price_range <- renderUI({
    req(input$car_brand)
    input$car_brand
    if (input$car_brand != "All") {
      min_price <-
        round(min(as.integer(total_data_parsed$Cena[total_data_parsed$brand %in% input$car_brand])), digits = -3)
      max_price <-
        round(max(as.integer(total_data_parsed$Cena[total_data_parsed$brand %in% input$car_brand])), digits = -3)
    } else {
      min_price <- round(min(as.integer(total_data_parsed$Cena)), digits = -3)
      max_price <- round(max(as.integer(total_data_parsed$Cena)), digits = -3)
    }
    sliderInput(
      "price_range",
      h4("Select price range:"),
      min = 0,
      max = max_price + 1,
      value = c(min_price, max_price),
      sep = "",
      step = 1000
    )
  })
  
  # reactive event e.g. parse data to html to make it workable with chart.js
  dataChartJS_scatter <- eventReactive({
    # any changes in input will adjust table
    input$year_range
    input$car_brand
    input$car_model
    input$price_range
  }, {
    # it is required only brand car to do initial dash statistics
    req(input$car_brand)
    req(input$car_model)
    req(input$year_range)
    req(input$price_range)
    # creat heat map
    
    fun_color_range <- colorRampPalette(c("blue", "red"))
    color <- data.frame(odo = seq(
      min(total_data_parsed$Nobrauk., na.rm = TRUE),
      max(total_data_parsed$Nobrauk., na.rm = TRUE),
      by = 100000
    ))
    color$color <- fun_color_range(nrow(color))
    
    if (input$car_brand == "All") {
      df_by_price <- total_data_parsed %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        filter(Cena >input$price_range[1] & Cena < input$price_range[2]) %>%
        select(
          odo = `Nobrauk.`,
          year = Gads,
          price = Cena,
          model = Modelis,
          brand
        )  %>%
        mutate(
          bucket_price = cut(
            price,
            breaks = c(-Inf, seq(0, 30000, by =
                                   2000),+Inf),
            labels = as.character(c(-Inf, seq(0, 30000, by =
                                                2000)))
          ),
          ordered_result = TRUE
        ) %>%
        # as.factor and .drop false to fill with 0 chart
        group_by(
          labels = as.factor(bucket_price),
          label = as.factor(brand),
          .drop = FALSE
        ) %>%
        summarise(x = n(), .groups = "drop") %>%
        # group small cars to 'Other group
        group_by(label) %>%
        mutate(check = ifelse(sum(x) < 250, 1, 0)) %>%
        ungroup() %>%
        mutate(label = as.factor(ifelse(
          check == 1, "Other", as.character(label)
        ))) %>%
        group_by(labels, label, .drop = FALSE) %>%
        summarise(x = sum(x)) %>%
        ungroup() %>%
        #TODO:filter unused bonds well make it better later
        filter(labels != '-Inf')
      
      df_price_vs_range <- total_data_parsed %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        filter(Cena >input$price_range[1] & Cena < input$price_range[2]) %>%
        select(odo = `Nobrauk.`,
               price = Cena) %>% 
        mutate(
          labels = cut(
            odo,
            breaks = c(-Inf, seq(0, 250000, by =
                                   10000),+Inf),
            labels = as.character( c(-Inf,seq(0, 250000, by =
                                                10000)))
          ),
          ordered_result = TRUE
        ) %>% 
        group_by(labels) %>%
        summarise(x = floor(mean(price))) %>%
        ungroup()
      
      df_by_brand_total <- total_data_parsed %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        filter(Cena >input$price_range[1] & Cena < input$price_range[2]) %>%
        group_by(labels = brand) %>%
        summarise(x = n()) %>%
        ungroup() %>%
        mutate(labels = ifelse(x < 100, 'Other', labels)) %>%
        group_by(labels) %>%
        summarise(x = sum(x)) %>%
        arrange(-x) %>%
        ungroup()
      
      
      df <- jsonlite::toJSON(list(df_by_price, 'bar_stacked',df_price_vs_range, df_by_brand_total))
    } else {
      if (input$car_model == "All") {
        models <- unique(total_data_parsed$Modelis)
      } else {
        models <- input$car_model
      }
      
      df <- total_data_parsed  %>%
        # brand
        filter(brand %in%  input$car_brand) %>%
        # model
        filter(Modelis %in% models) %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        filter(Cena >input$price_range[1] & Cena < input$price_range[2]) %>%
        # y = price, x = year to unify chart.js for further uses.
        select(
          odo = `Nobrauk.`,
          x = Gads,
          y = Cena,
          model = Modelis,
          brand
        ) %>%
        # group_by(brand, model, year) %>%
        # summarise(price = mean(price), odo = mean(odo)) %>%
        # ungroup() %>%
        mutate(color =  color$color[findInterval(odo, color$odo)])
      df <- jsonlite::toJSON(list(df, 'scatter'))
    }
    
    
  })
  
  # sending json object of filtered countries data
  
  observe(
    session$sendCustomMessage(type = "dataChartJS_scatter", message = dataChartJS_scatter())
  )
  
  # to log out reactive table use observer()
  # observe(print(dataChartJS_scatter()))
  #dashboard
  
  output$car_stats_dashboard <-
    renderUI(includeHTML('www/index.html'))
  
})
