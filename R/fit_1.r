setwd("/global/u2/b/bbrusco/spatial-prediction")
library(tidyverse)
library(sf)
library(spdep)
library(CARBayesST)



## 1. Loading dataset and geometries ###
vars <- read_csv("data/processed/combined.csv")

county <- read_sf(
    dsn = "data/shapefile/cb_2020_us_tract_500k",
    layer = "cb_2020_us_tract_500k"
)

county <- county %>%
    mutate(FIPSCODE = paste0(STATEFP, COUNTYFP)) %>% 
    arrange(FIPSCODE) %>%
    distinct(FIPSCODE, .keep_all = TRUE)

df <- county %>% inner_join(vars, on=FIPSCODE)

df_nona <- df %>% na.omit(suicide_rate) %>%
  group_by(FIPSCODE) %>% 
  mutate(name_count = n()) %>%
  ungroup() %>% 
  filter(name_count == 4) %>% 
  dplyr::select(-name_count) %>%
  arrange(desc(year), FIPSCODE)

fips_to_keep <- df_nona %>% 
    distinct(FIPSCODE) %>% 
    pull(FIPSCODE)


#length(fips_to_keep)
#1931

## 2. Creating the neighbours matrix. See file create_neighbours_matrix.R ###

### Method 1: Binary Matrix

### Method 2: Nearest Neighbour (to use if we don't have a full counties dataset).


test_model <- ST.CARar(
    deaths ~ NHC_LIC_STAFF,
    df_nona,
    family="poisson",
    AR=1,
    W=neighbours_matrix
)