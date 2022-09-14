library(tidyverse)
library(sf)
library(spdep)


setwd("/global/project/projectdirs/m1532/Projects_MVP/geospatial/GeoSpatial_Model/spatial-prediction")



vars_to_remove <- c(
    "STATEFP", "COUNTYFP", "TRACTCE", "AFFGEOID",
    "GEOID", "NAME", "NAMELSAD", "STUSPS", "NAMELSADCO",
    "STATE_NAME", "LSAD", "geometry", "FIPSCODE", "county",
    "year","deaths","pop", "ALAND", "AWATER","closest_station_index", "distance_centroid"
)

vars_to_remove_fe <- c(
    "STATEFP", "COUNTYFP", "TRACTCE", "AFFGEOID",
    "GEOID", "NAME", "NAMELSAD", "STUSPS", "NAMELSADCO",
    "STATE_NAME", "LSAD", "geometry", "FIPSCODE", "county",
    "year","deaths","pop", "ALAND", "AWATER","closest_station_index", "distance_centroid"
)


# Function to create neighbours matrix

create_neighbours_matrix <- function(fips_to_keep, county){

    counties_keep <- county %>%
    filter(FIPSCODE %in% fips_to_keep)

    county_nb <- spdep::poly2nb(
        st_geometry(counties_keep)
    )
    mat <- spdep::nb2mat(
    county_nb,
    style="B",
    zero.policy=TRUE
    )
    return(mat)
}


# create dataset with no NA

make_df_nona <- function(){

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
    return(df_nona)
}

get_noncollinear_predictors <- function(df_nona, vars_to_remove){
    corr_mat = df_nona %>%
        dplyr::select(-all_of(c(vars_to_remove))) %>% cor()

    hc = caret::findCorrelation(corr_mat, cutoff=0.90) 
    hc = sort(hc)
    hc_names <- colnames(corr_mat[hc,hc])[-1]

    predictors  <- setdiff(colnames(df_nona), c(vars_to_remove,hc_names))
    return(predictors)
}