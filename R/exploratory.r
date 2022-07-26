setwd("/global/u2/b/bbrusco/spatial-prediction")
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
    }
    plot(state_df["suicide_rate"])
    title(paste("Suicide Rate,", state))
    dev.off()
}

# Some state plots
plot_state("California")
plot_state("New York")
plot_state("Colorado")
plot_state("Washington")
plot_state("Illinois")
plot_state("Florida")



# issues with GDAL version
# ggplot() + geom_sf(data = county) + theme_bw()