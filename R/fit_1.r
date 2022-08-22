setwd("/global/u2/b/bbrusco/spatial-prediction")
library(tidyverse)
library(sf)
library(spdep)
library(CARBayesST)


DATE <- Sys.Date()
OUT_PATH <- paste0("outputs/model_results/model_", DATE,".rds")

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
    "deaths", "pop", "crude_rate", "adj_rate","suicide_rate",
    "year"
)

model_formula <- as.formula(
    paste("deaths ~ offset(log(pop)) +", paste(
        setdiff(colnames(df_nona), vars_to_remove),
        collapse= "+")
         )
)

model <- ST.CARar(
    model_formula,
    df_nona,
    family="poisson",
    AR=1,
    W=neighbours_matrix,
    burnin=10000,
    n.sample=50000
)

# saveRDS(model, OUT_PATH)

# for prediction: set the outcome variable to NAN (deaths)
# for these NAN values we get the posterior distributions via
# model$samples$Y

# And the average predictive posterior distributions via
# predicted_values <- colMeans(model$samples$Y)


# Finding RMSE
# TRUE_VALUES <- from hold out dataset
# caret::RMSE(predicted_values, TRUE_VALUES)