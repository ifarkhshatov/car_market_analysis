options(dplyr.summarise.inform = FALSE)
options(scipen = 999)
# options(browser = 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe')
# options(shiny.launch.browser = .rs.invokeShinyWindowExternal)
    
library(shiny)
library(shinyWidgets)
library(shinydashboard)
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  #BRAND SELECTOR
  output$car_brand <- renderUI({
    selected = 'All'
    # use names() to show only name not content of select input
    selectInput(
      "car_brand",
      label = h4("Select Brand:"),
      selected = selected,
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
    numericRangeInput(
      "price_range",
      h4("Select price range:"),
      min = 0,
      max = 500000,
      value = c(0, 100000),
      sep = "",
      step = 500
    )
    
  })
  
  # Odometer range
  output$odo_range <- renderUI({
    req(input$car_brand)
    input$car_brand
    numericRangeInput(
      "odo_range",
      h4("Select Odometer range:"),
      min = NA,
      max = 1000000,
      value = c(-1, 1000000),
      sep = "",
      step = 5000
    )
    
  })
  
  # reset data
  output$reset <- renderUI({
    actionButton(label = 'Reset filters', "reset")
    
  })
  
  # reactive event e.g. parse data to html to make it workable with chart.js
  dataChartJS_scatter <- eventReactive({
    # any changes in input will adjust table
    input$year_range
    input$car_brand
    input$car_model
    input$price_range
    input$odo_range
  }, {
    # it is required only brand car to do initial dash statistics
    req(input$car_brand)
    req(input$car_model)
    req(input$year_range)
    req(input$price_range)
    req(input$odo_range)
    # creat heat map

    if (input$car_brand == "All") {
      filtered_df <-  total_data_parsed %>%
        #temporarly fix NA values in odometer
        mutate(Nobrauk. = ifelse(is.na(Nobrauk.), -1, Nobrauk.)) %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        filter(Cena > input$price_range[1] &
                 Cena < input$price_range[2]) %>%
        filter(Nobrauk. >= input$odo_range[1] &
                 Nobrauk. <= input$odo_range[2])
      
      # Chart where distribution of avg price and odometer value
      df_price_vs_range <- filtered_df %>%
        select(odo = `Nobrauk.`,
               price = Cena) %>%
        mutate(
          labels = cut(
            odo,
            breaks = c(-Inf, seq(0, 250000, by =
                                   10000), +Inf),
            labels = as.character(c("No data", seq(0, 250000, by =
                                                     10000)))
          ),
          ordered_result = TRUE
        ) %>%
        group_by(labels) %>%
        summarise(x = floor(mean(price))) %>%
        ungroup()
      # group by brand and it's quantity
      df_by_brand_total <- filtered_df %>%
        group_by(labels = brand) %>%
        summarise(x = n()) %>%
        ungroup() %>%
        # mutate(labels = ifelse(x < 100, 'Other', labels)) %>%
        # group_by(labels) %>%
        # summarise(x = sum(x)) %>%
        arrange(-x) #%>%
      # ungroup()
      # distribution by year and its mean price
      df_by_year_and_price <- filtered_df %>%
        mutate(
          labels = cut(
            Gads,
            breaks = c(-Inf, seq(1990, 2023, by =
                                   1)),
            labels = as.character(c("up to 1990",seq(
              1991, 2023, by =
                1
            )))
          ),
          ordered_result = TRUE
        ) %>%
        group_by(labels) %>%
        summarise(x = floor(mean(Cena)))

      # group by year and count cars
      df_by_year_and_quantity <- filtered_df %>%
        mutate(
          labels = cut(
            Gads,
            breaks = c(-Inf, seq(1990, 2023, by =
                                   1)),
            labels = as.character(c("up to 1990",seq(
              1991, 2023, by =
                1
            )))
          ),
          ordered_result = TRUE
        ) %>%
        group_by(labels) %>%
          summarise(x = n()) 
      
      df <-
        jsonlite::toJSON(
          list(
            '',
            'bar_stacked',
            df_price_vs_range,
            df_by_brand_total,
            df_by_year_and_price,
            df_by_year_and_quantity
          )
        )
    } else {
      if (input$car_model == "All") {
        models <- unique(total_data_parsed$Modelis)
      } else {
        models <- input$car_model
      }
      
      
      filtered_df <-  total_data_parsed %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        filter(Cena > input$price_range[1] &
                 Cena < input$price_range[2]) %>%
        filter(brand == input$car_brand)
      
      # Chart where distribution of avg price and odometer value
      df_price_vs_range <- filtered_df %>%
        filter(Modelis %in% models) %>%
        select(odo = `Nobrauk.`,
               price = Cena) %>%
        mutate(
          labels = cut(
            odo,
            breaks = c(-Inf, seq(0, 250000, by =
                                   10000), +Inf),
            labels = as.character(c(-Inf, seq(0, 250000, by =
                                                10000)))
          ),
          ordered_result = TRUE
        ) %>%
        group_by(labels) %>%
        summarise(x = floor(mean(price))) %>%
        ungroup()
      
      
      # group by brand/model and it's quantity
      df_by_brand_total <- filtered_df %>%
        group_by(labels = Modelis) %>%
        summarise(x = n()) %>%
        ungroup() %>%
        arrange(-x)

      # group by year and count cars
      df_by_year_and_quantity <- filtered_df %>%
          filter(Modelis %in% models) %>%
          group_by(labels = Gads) %>%
          summarise(x = n()) 
      
      
      # distribution by year and its mean price
      df_by_year_and_price <- filtered_df %>%
        filter(Modelis %in% models) %>%
        mutate(
          labels = cut(
            Gads,
            breaks = c(-Inf, seq(1990, 2023, by =
                                   1)),
            labels = as.character(c(seq(
              1990, 2023, by =
                1
            )))
          ),
          ordered_result = TRUE
        ) %>%
        group_by(labels) %>%
        summarise(x = floor(mean(Cena)))
      
      
      df <-
        jsonlite::toJSON(
          list(
            '',
            'bar_stacked',
            df_price_vs_range,
            df_by_brand_total,
            df_by_year_and_price,
            df_by_year_and_quantity
          )
        )
    }
    
    
  })
  
  # sending json object of filtered countries data
  
  observe(
    session$sendCustomMessage(type = "dataChartJS_scatter", message = dataChartJS_scatter())
  )
  # return value from JS to update input$car_brand
  observeEvent(input$returnFromUI, {
    id = input$returnFromUI$id
    # if (id == "chart-stats-0" & input$car_brand == 'All') {
    #   selected = input$returnFromUI$x_value
    #   updateSelectInput(inputId = 'car_brand', selected = selected)
    # } else if (id == "chart-stats-0") {
    #   selected = input$returnFromUI$x_value
    #   updateSelectInput(inputId = 'car_model', selected = selected)
    # }
    # if (id == "chart-stats-1") {
    #   values = c(
    #     as.numeric(input$returnFromUI$x_value) - 10000,
    #     as.numeric(input$returnFromUI$x_value)
    #   )
    #   if (!identical(values, numeric(0))) {
    #     updateNumericRangeInput(inputId = 'odo_range', value = values)
    #   }
    # }
    print(input$returnFromUI$activeBar)
    if (id == "chart-stats-0" && length(input$returnFromUI$activeBar) == 1 ) {
      insertTab("tabset1",tabPanel(input$returnFromUI$x_value,"test"), target = "Brands Distribution" )
    } else {
      removeTab("tabset1", target = input$returnFromUI$x_value)
    }
  })

  # send all filters from dashboard
  observe(session$sendCustomMessage(type = "filterData",
                                    message = jsonlite::toJSON(
                                      list(
                                        input$year_range,
                                        input$car_brand,
                                        input$car_model,
                                        input$price_range
                                      )
                                    )))
  
  
  # Reset filter
  observe({
    input$reset
    updateSelectInput(session, inputId = 'car_brand', selected = 'All')
    updateNumericRangeInput(session,
                            inputId = 'odo_range',
                            value = c(-1, 1000000))
    updateNumericRangeInput(session, inputId = 'price_range', value = c(0, 100000))
    updateSliderInput(session, inputId = 'year_range', value = c(1949, 2022))
  })
  
  output$car_stats_dashboard <-
    renderUI(tabBox(
      id = "tabset1",
      tabPanel(
        "Brands Distribution",
        div(class = "charts",
            div(class = "chart"))
      ),
      # tabPanel("Models Distribution","test")
    ))
  output$car_chart2 <-
    renderUI(tabBox(id = "tabset2",
                    tabPanel(
                      "Ø Price to Odometer",
                      div(class = "charts",
                          div(class = "chart"))
                    ),
                    #tabPanel("Tab2")
                    ))
  output$car_chart3 <-
    renderUI(tabBox(id = "tabset2",
                    tabPanel(
                      "Ø Price to Year",       div(class = "charts",
                                         div(class = "chart"))
                    ),
                   # tabPanel("Tab2")
                    ))
  output$car_chart4 <-
    renderUI(tabBox(id = "tabset3",
                    tabPanel(
                      "Year Distribution",       div(class = "charts",
                                         div(class = "chart"))
                    ),
                   # tabPanel("Tab2")
                    ))                  
  
})
