"Model with spatial and random effects"

setwd("/global/project/projectdirs/m1532/Projects_MVP/geospatial/GeoSpatial_Model/spatial-prediction")
library(tidyverse)
library(sf)
library(spdep)
library(CARBayesST)
library(caret)

source("./R/utils.r")

DATE <- Sys.Date()
OUT_PATH <- paste0(
    "outputs/model_results/model_",
    DATE,
    ".rds"
)

## 1. Loading dataset and geometries ###
df_nona <- make_df_nona()


## 2. Creating the neighbours matrix. See file create_neighbours_matrix.R ###
### Method 1: Binary Matrix
### Method 2: Nearest Neighbour (to use if we don't have a full counties dataset).
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
    AR=1,
    W=neighbours_matrix,
    burnin=10000,
    n.sample=80000
)

saveRDS(model, OUT_PATH)