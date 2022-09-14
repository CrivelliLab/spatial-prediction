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

source("./R/utils.r")

## 1. Loading dataset and geometries ###
df_nona <- make_df_nona()


## 2. Creating the neighbours matrix. See file create_neighbours_matrix.R ###
### Method 1: Binary Matrix
### Method 2: Nearest Neighbour (to use if we don't have a full counties dataset).
neighbours_matrix <- readRDS(
    file = "data/processed/neighbours_matrix.rds"
)

predictors <- get_noncollinear_predictors(df_nona, vars_to_remove_fe)

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