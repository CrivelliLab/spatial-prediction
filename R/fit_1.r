setwd("/global/u2/b/bbrusco/spatial-prediction")
library(tidyverse)
library(sf)
library(carbayesst)



## Loading dataset and geometries ###
vars <- read_csv("data/processed/combined.csv")
df <- county %>% left_join(vars, on=FIPSCODE)

## TODO : rearrange data so that it fits the model appropriately

##

## Fix matrix weight list
county_lw <- readRDS("data/processed/county_weight_list.rds")