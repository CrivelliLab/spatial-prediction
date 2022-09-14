"Model with spatial and random effects- AR 2 (same as FIT 1 but with AR2 instead of AR1)"

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

source("./R/utils.r")

## 1. Loading dataset and geometries ###
df_nona <- make_df_nona()

## 2. Creating the neighbours matrix. See file create_neighbours_matrix.R ###

neighbours_matrix <- readRDS(
    file = "data/processed/neighbours_matrix.rds"
)

predictors <- get_noncollinear_predictors(df_nona, vars_to_remove)

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