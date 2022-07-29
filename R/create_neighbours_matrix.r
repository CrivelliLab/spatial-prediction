setwd("/global/u2/b/bbrusco/spatial-prediction")
library(tidyverse)
library(sf)

## Loading dataset and geometries ###
vars <- read_csv("data/processed/combined.csv")
county <- read_sf(
    dsn = "data/shapefile/cb_2020_us_tract_500k",
    layer = "cb_2020_us_tract_500k"
)

county <- county %>%
    mutate(FIPSCODE = paste0(STATEFP, COUNTYFP))

df <- county %>% left_join(vars, on=FIPSCODE)

df_nona <- df %>% na.omit(suicide_rate)

county_nb <- spdep::poly2nb(
    st_geometry(df_nona)
)
county_lw <- spdep::nb2listw(
    county_nb, style="B", zero.policy=TRUE
)

neighbours_matrix <- spdep::nb2mat(
    county_nb,
    style="B",
    zero.policy=TRUE
)

row.names(adj_matrix) <- NULL