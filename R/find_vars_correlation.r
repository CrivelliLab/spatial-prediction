"File to find correlation among the predictor variables"

setwd("/global/project/projectdirs/m1532/Projects_MVP/geospatial/GeoSpatial_Model/spatial-prediction")
library(tidyverse)
library(sf)
library(caret)

CORR_CUTOFF  = 0.99

## 1. Loading dataset and geometries ###
vars <- read_csv("data/processed/combined.csv")
NUMBER_OF_YEARS <- length(unique(vars$year))

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
  filter(name_count == NUMBER_OF_YEARS) %>% 
  dplyr::select(-name_count) %>%
  arrange(desc(year), FIPSCODE) %>% as_tibble()


vars_to_remove <- c(
    "STATEFP", "COUNTYFP", "TRACTCE", "AFFGEOID",
    "GEOID", "NAME", "NAMELSAD", "STUSPS", "NAMELSADCO",
    "STATE_NAME", "LSAD", "geometry", "FIPSCODE", "county",
    "suicide_rate","year"
)



corr_mat = df_nona %>%
    dplyr::select(-all_of(vars_to_remove)) %>% cor()

hc = caret::findCorrelation(corr_mat, cutoff=CORR_CUTOFF) 
hc = sort(hc)
print(colnames(corr_mat[hc,hc]))
