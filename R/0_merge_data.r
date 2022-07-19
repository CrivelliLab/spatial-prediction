setwd("/global/u2/b/bbrusco/spatial-prediction")
library(tidyverse)

years <- c(2015,2016,2017,2018)

make_yearly <- function(y){
    sdoh <- read_csv(
        paste0("data/raw/sdoh/",y,".csv"),
        show_col_types = FALSE
    ) |>
    mutate(year=y)
    
    suicide <- read_csv(
        paste0("data/raw/suicide/",y,".txt"),
        col_names = c("county","FIPSCODE", "deaths", "pop", "crude_rate", "adj_rate","suicide_rate"),
        skip=1,
        show_col_types = FALSE,
    ) |> merge(sdoh, on = "FIPSCODE")
    
    return(suicide)
}

dfs <- lapply(years, make_yearly)
df <- do.call("rbind", dfs)
df |> write_csv("data/processed/combined.csv")









