library(readr)
library(magrittr)
library(tidyverse)
library(rvest)
library(janitor)
library(ggplot2)
setwd(stringr::str_sub(
  as.character(rstudioapi::getActiveDocumentContext()$path),
  end = -12
))
# i used rvest since i search the easier way to parse this site. without docker container etc
# find brands
data_brands <- read_html("https://www.ss.com/lv/transport/cars/sell/filter/") %>% 
  html_elements('.category') %>% {.[1:40]}
# based data category and links to search.
check_data <- data.frame(
  brand = data_brands %>% html_text2(),
  link = 
    paste0('https://www.ss.com/',data_brands %>% html_elements('a') %>% html_attr('href'))
)

total_data <- data.frame()
# for each brand i go through pages
for (brand in c(1:5)) { # c(1:nrow(check_data))
  Sys.sleep(2)
  print(check_data$brand[brand])
  link <- check_data$link[brand]
  # randomly chosen page, if .navia class is not the same as number of page then break
  for (page in c(1:100)) {
    Sys.sleep(0.5)
    page_link <- paste0(link,"page",page,".html")
    print(page_link)
    navia_num <- read_html(page_link)
    page_num <- navia_num  %>%
      #.navia is page number
      html_elements('.navia') %>% html_text2()
    # if there only 1 page, then we set to loop only first page.
    page_num <- ifelse(identical(page_num,character(0)), 1, page_num)
# need to add link to ads 
# date of publishing
# vin, plate
# something else (phone maybe)    
    if (page_num != page) {
      break
    } else {

      t_data <- navia_num %>%
        html_nodes(xpath = '//*[@id="filter_frm"]/table[2]') %>% 
        html_table() %>% 
        as.data.frame() %>%
        select(c(2:8)) %>%
        select(-1) %>%
        row_to_names(row_number=1) %>%
        slice(1:(n()-1)) %>%
        mutate(brand = check_data$brand[brand])
      # find unique id for advertisement instead of VIN for now
      link_and_id_data <- navia_num %>%
        html_elements('.d1 a') %>% 
        html_attr('href') %>% 
        str_extract("([^\\/]+$)") %>%
        str_replace_all(".html","")
        # filter duplicated cars
        # t_data <- t_data %>% mutate(link = link_and_id_data) %>% 
        #   filter(link %in% total_data$link)
      
      total_data <- bind_rows(total_data, t_data)
      rm(t_data)
    }
  }
}

#make data great again
total_data_parsed <- total_data %>%
  mutate(Cena = str_replace_all(Cena, c(" " = "", "€" = "", "," = "")) %>% as.numeric(),
         `Nobrauk.` = str_replace_all(`Nobrauk.`, c("tūkst." = "000", " " ="", "-"= NA,","="")) %>% as.numeric()) %>%
  mutate(Gads = as.numeric(Gads))

save(total_data_parsed, file = "data.rda")
# 
# write.csv(
#   x = total_data_parsed,
#   file = "ss.csv",
#   fileEncoding = "UTF-8",
#   na = "",
#   row.names = FALSE
# )
