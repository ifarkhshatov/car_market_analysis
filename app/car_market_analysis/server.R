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
      choices = c("All", unique(total_data_parsed$brand)),
      multiple = TRUE
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

    # there is no sense to parse data, just take 1900 till 2023

    sliderInput(
      "year_range",
      h4("Select year range:"),
      min = 1900,
      max = as.numeric(format(Sys.Date(), format = "%Y"))  + 1,
      value = c(1940, as.numeric(format(Sys.Date(), format = "%Y"))),
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
  # Main data filter which relates to to all chart
  filtered_df <- eventReactive(
    {input$year_range
    input$price_range
    input$odo_range}, {

    total_data_parsed %>%
    #temporarly fix NA values in odometer
    mutate(Nobrauk. = ifelse(is.na(Nobrauk.), -1, Nobrauk.)) %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        filter(Cena > input$price_range[1] &
                 Cena < input$price_range[2]) %>%
        filter(Nobrauk. >= input$odo_range[1] &
                 Nobrauk. <= input$odo_range[2])
  })

         #Main chart, since now it can be affected by other filters but we need only: year, odo, price
  dataChartJS_parent_charts <- eventReactive(filtered_df(), {
   # group by brand and it's quantity
    dataChartJS_parent_charts <- filtered_df() %>%
        group_by(labels = brand) %>%
        summarise(x = n()) %>%
        ungroup() %>%
    # mutate(labels = ifelse(x < 100, 'Other', labels)) %>%
    # group_by(labels) %>%
    # summarise(x = sum(x)) %>%
    arrange(-x) #%>%
    # ungroup()
      jsonlite::toJSON(dataChartJS_parent_charts)
     })



  # reactive event e.g. parse data to html to make it workable with chart.js
  dataChartJS_child_charts <- eventReactive({
    # any changes in input will adjust table
    input$car_brand
    input$car_model
    filtered_df()
  }, {
    # it is required only brand car to do initial dash statistics
    req(input$car_brand)
    req(input$car_model)
    req(filtered_df())

   # distribution by year and its mean price
    df_by_year_and_price <- filtered_df() %>%
        mutate(
          labels = cut(
            Gads,
            breaks = c(-Inf, seq(1990, 2023, by =
                                   1)),
            labels = as.character(c("up to 1990", seq(
              1991, 2023, by =
                1
            )))
          ),
          ordered_result = TRUE
        ) %>%
        group_by(labels) %>%
        summarise(x = floor(mean(Cena)))
    # Chart where distribution of avg price and odometer value
    df_price_vs_range <- filtered_df() %>%
        select(odo = `Nobrauk.`,
               price = Cena) %>%
        mutate(
          labels = cut(
            odo,
            breaks = c(-Inf, seq(0, 250000, by =
                                   10000), + Inf),
            labels = as.character(c("No data", seq(0, 250000, by =
                                                     10000)))
          ),
          ordered_result = TRUE
        ) %>%
        group_by(labels) %>%
        summarise(x = floor(mean(price))) %>%
        ungroup()

    # group by year and count cars
    df_by_year_and_quantity <- filtered_df() %>%
        mutate(
          labels = cut(
            Gads,
            breaks = c(-Inf, seq(1990, 2023, by =
                                   1)),
            labels = as.character(c("up to 1990", seq(
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
            '',
            df_by_year_and_price,
            df_by_year_and_quantity
          )
        )
  })

  # sending json object of filtered depended data
  observe(
    session$sendCustomMessage(type = "dataChartJS_child_charts", message = dataChartJS_child_charts()  ),
  )
  # sending json object of filtered parent data (BRAND VS QUANTITY)
  observe(
    session$sendCustomMessage(type = "dataChartJS_parent_charts", message = dataChartJS_parent_charts() ),
  )
  # return value from JS to update input$car_brand
  observeEvent(input$returnFromUI, {
    id = input$returnFromUI$id
    x_value = input$returnFromUI$x_value
    activeBar = input$returnFromUI$activeBar

    # option to click on bar either change on menu CAR BRAND, now can be multiple
    if (id == "chart-stats-0") {
      if (length(activeBar) == 0) {
        print('All')
      } else {
        print(activeBar)
      }
      updateSelectInput(inputId = 'car_brand', choices = activeBar, selected = activeBar)
    }
    # open tab with model distribution if selected 
    if (id == "chart-stats-0" && x_value %in% activeBar) {

      insertTab("tabset1", tabPanel(x_value, div(class = "charts", div(class = "chart-brand"))), target = "Brands Distribution")

      test_data <- list()
      for (i in activeBar) {
        test_data[[i]] <- total_data_parsed %>%
        filter(Gads %in% seq(input$year_range[1], input$year_range[2])) %>%
        filter(Cena > input$price_range[1] &
                 Cena < input$price_range[2]) %>%
        filter(brand == i) %>%
        group_by(labels = Modelis) %>%
        summarise(x = n()) %>%
        ungroup() %>%
        arrange(-x)
      }

      session$sendCustomMessage(type = "tabModelOpened", message = jsonlite::toJSON(list(test_data, unlist(activeBar), id) ))

      # if double click to close opened tabs of models
    } else if (id == "chart-stats-0" && length(activeBar) > 5) {

    } else if (id == "chart-stats-0" && length(activeBar) == 0) {

      for (i in unique(total_data_parsed$brand)) {
        removeTab("tabset1", target = i)
      }

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

  output$car_chart1 <-
    renderUI(tabBox(
      id = "tabset1",
      tabPanel(
        "Brands Distribution",
        div(class = "charts",
            div(class = "chart"))
      )
    ))
  output$car_chart2 <-
    renderUI(tabBox(id = "tabset2",
                    tabPanel(
                      "Ø Price to Odometer",
                      div(class = "charts",
                          div(class = "chart"))
                    )
                    ))
  output$car_chart3 <-
    renderUI(tabBox(id = "tabset2",
                    tabPanel(
                      "Ø Price to Year", div(class = "charts",
                                         div(class = "chart"))
                    )
                    ))
  output$car_chart4 <-
    renderUI(tabBox(id = "tabset3",
                    tabPanel(
                      "Year Distribution", div(class = "charts",
                                         div(class = "chart"))
                    )
                    ))

})
