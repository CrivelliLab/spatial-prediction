"Model with spatial and random effects- AR 2 (same as FIT 1 but with AR2 instead of AR1"

setwd("/global/project/projectdirs/m1532/Projects_MVP/geospatial/GeoSpatial_Model/spatial-prediction")
library(tidyverse)
library(sf)
library(spdep)
library(CARBayesST)
library(caret)

DATE <- Sys.Date()
OUT_PATH <- paste0(
    "outputs/model_results/AR2model_",
    DATE,
    ".rds"
)

## 1. Loading dataset and geometries ###
vars <- read_csv("data/processed/combined.csv")
# you are considering in your dataset.
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

#length(fips_to_keep)
#1931

## 2. Creating the neighbours matrix. See file create_neighbours_matrix.R ###

### Method 1: Binary Matrix

### Method 2: Nearest Neighbour (to use if we don't have a full counties dataset).
neighbours_matrix <- readRDS(
    file = "data/processed/neighbours_matrix.rds"
)


vars_to_remove <- c(
    "STATEFP", "COUNTYFP", "TRACTCE", "AFFGEOID",
    "GEOID", "NAME", "NAMELSAD", "STUSPS", "NAMELSADCO",
    "STATE_NAME", "LSAD", "geometry", "FIPSCODE", "county",
    "year","deaths","pop"
)



# vars_to_remove <- c(
#    "STATEFP", "COUNTYFP", "TRACTCE", "AFFGEOID",
#    "GEOID", "NAME", "NAMELSAD", "STUSPS", "NAMELSADCO",
#    "STATE_NAME", "LSAD", "geometry", "FIPSCODE", "county",
#    "crude_rate", "adj_rate","suicide_rate","year"
# ) 


#df_nona[df_nona$year == 2018, "deaths"] = NA

corr_mat = df_nona %>%
    dplyr::select(-all_of(c(vars_to_remove))) %>% cor()

hc = caret::findCorrelation(corr_mat, cutoff=0.99) 
hc = sort(hc)
# ACS_PCT_RENTED_HH	ACS_PCT_TRICARE_VA	ACS_TOTAL_HOUSEHOLD
hc_names <- colnames(corr_mat[hc,hc])[-1]

predictors  <- setdiff(colnames(df_nona), c(vars_to_remove,hc_names))

model_formula <- as.formula(
    paste("deaths ~ offset(log(pop)) +",
       paste(
        predictors,
        collapse= "+"
       )
    )
)


model <- ST.CARar(
    model_formula,
    df_nona,
    family="poisson",
    AR=2,
    W=neighbours_matrix,
    burnin=10000,
    n.sample=80000
)

saveRDS(model, OUT_PATH)

# for prediction: set the outcome variable to NAN (deaths)
# for these NAN values we get the posterior distributions via
# model$samples$Y

# And the average predictive posterior distributions via
# predicted_values <- colMeans(model$samples$Y)


# Finding RMSE
# TRUE_VALUES <- from hold out dataset
# caret::RMSE(predicted_values, TRUE_VALUES)