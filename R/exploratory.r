setwd("/global/project/projectdirs/m1532/Projects_MVP/geospatial/GeoSpatial_Model/spatial-prediction")
library(tidyverse)
library(sf)

## Loading dataset and geometries ###
vars <- read_csv("data/processed/combined.csv")
county <- read_sf(
    dsn = "data/shapefile/cb_2020_us_tract_500k",
    layer = "cb_2020_us_tract_500k"
)

county <- county %>%
    mutate(FIPSCODE = paste0(STATEFP, COUNTYFP))

df <- county %>% left_join(vars, on=FIPSCODE)

### For plotting purposes ###

# restrict to only continental U.S.
continental <- st_crop(
    df,
    xmin = -130, xmax = -45,
    ymin = 20, ymax = 50
)

plot(continental["suicide_rate"])

plot_state <- function(state, save = TRUE){
    state_df <- df %>% filter(STATE_NAME == state)
    if(save == TRUE){
        png(paste0("outputs/imgs/rates_",state,".png"))
        plot(state_df["suicide_rate"])
        title(state)
        dev.off()
    }
    return(plot(state_df["suicide_rate"]))
}


# Some state plots
plot_state("California")
plot_state("New York")
plot_state("Colorado")
plot_state("Washington")
plot_state("Illinois")
plot_state("Florida")



# issues with GDAL version
# ggplot(data=df_nona) + geom_sf(fill=suicide_rate) + theme_bw()



### Computing Moran's I

county_lw <- readRDS("data/processed/county_weight_list.rds")
mt <- spdep::moran.test(df_nona$suicide_rate, county_lw)

### Moran's I test results:
# Moran I test under randomisation

# data:  df_nona$suicide_rate  
# weights: count_lw    

# Moran I statistic standard deviate = 1804.3, p-value < 2.2e-16
# alternative hypothesis: greater
# sample estimates:
# Moran I statistic       Expectation          Variance 
#      8.500109e-01     -3.065726e-06      2.219363e-07 