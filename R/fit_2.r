"Fit 2: linear trend and spatial random effects"

setwd("/global/project/projectdirs/m1532/Projects_MVP/geospatial/GeoSpatial_Model/spatial-prediction")
library(tidyverse)
library(sf)
library(spdep)
library(CARBayesST)


DATE <- Sys.Date()
OUT_PATH <- paste0(
    "outputs/model_results/fixedtime_model_",
    DATE,
    ".rds"
)

## 1. Loading dataset and geometriecorr_mat = cor(design_matrix)
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

## 2. Creating the neighbours matrix. See file create_neighbours_matrix.R ###

### Method 1: Binary Matrix

### Method 2: Nearest Neighbour (to use if we don't have a full counties dataset).
neighbours_matrix <- readRDS(
    file = "data/processed/neighbours_matrix.rds"
)

vars_to_remove <- c(
    "STATEFP", "COUNTYFP", "TRACTCE", "AFFGEOID",
    "GEOID", "NAME", "NAMELSAD", "STUSPS", "NAMELSADCO",
    "STATE_NAME", "LSAD", "geometry", "FIPSCODE", "county", "year", "deaths","pop"
) # year incorporated by the ST.CARlinear model
corr_mat = df_nona %>%
    dplyr::select(-all_of(vars_to_remove)) %>% cor()

hc = caret::findCorrelation(corr_mat, cutoff=0.99) 
hc = sort(hc)
hc_names <- colnames(corr_mat[hc,hc])[-1]

design_matrix <- df_nona %>%
    dplyr::select(-all_of(vars_to_remove)) %>%
    dplyr::select(-all_of(hc))


predictors  <- setdiff(colnames(df_nona), c(vars_to_remove,hc_names))

model_formula <- as.formula(
    paste("deaths ~ offset(log(pop)) +",
       paste(
        predictors,
        collapse= "+"
       )
    )
)

model <- ST.CARlinear(
    model_formula,
    data=df_nona,
    family="poisson",
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