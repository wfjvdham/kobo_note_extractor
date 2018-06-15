library(tidyverse)
library(rvest)
library(stringr)
library(readr)

file <- list.files("./input", full.names = T)

notes <- file %>%
  read_html() %>%
  html_nodes("fragment") %>%
  html_text() %>%
  str_trim() %>%
  write_lines("./out.txt")
