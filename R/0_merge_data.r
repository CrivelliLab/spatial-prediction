setwd("/global/u2/b/bbrusco/spatial-prediction")
library(tidyverse)

COLNAMES <- c("county","FIPSCODE", "neighbours", "neighbours_code", "deaths")
years <- c(2016,2017,2018)

make_yearly <- function(y){
    sdoh <- read_csv(
        paste0("data/raw/sdoh/",y,".csv"),
        show_col_types = FALSE
    ) |>
    mutate(year=y)
    
    suicide <- read_csv(
        paste0("data/raw/suicide/",y,".csv"),
        skip=1,
        col_names= COLNAMES,
        show_col_types = FALSE,
    ) |>
    select(-c(neighbours, neighbours_code)) |> 
    merge(sdoh, on = "FIPSCODE")
    
    return(suicide)
}

dfs <- lapply(years, make_yearly)
df <- do.call("rbind", dfs)

demographic_info <- read_csv("data/raw/demo/2020-demographic-info.csv")
demographic_info <- demographic_info |>
    mutate(FIPSCODE = paste0(STATE, COUNTY)) |>
    select(FIPSCODE, CENSUS2010POP) |>
    rename(pop=CENSUS2010POP)


df <- df |> merge(demographic_info, on = "FIPSCODE") |> 
    mutate(deaths=as.integer(deaths))
                                                               
df |> na.omit(deaths) |> write_csv("data/processed/combined.csv")









