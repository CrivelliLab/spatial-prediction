setwd("/global/u2/b/bbrusco/spatial-prediction")
library(tidyverse)
library(sf)

## Loading dataset and geometries ###
vars <- read_csv("data/processed/combined.csv")
county <- read_sf(
    dsn = "data/shapefile/cb_2020_us_tract_500k",
    layer = "cb_2020_us_tract_500k"
) 

# Note: United States total includes 3,006 counties;
## Loading dataset and geometries ###
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

fips_to_keep <- df_nona %>% 
    distinct(FIPSCODE) %>% 
    pull(FIPSCODE)


#length(fips_to_keep)
#1931

### Method 1: Binary Matrix ###

counties_keep <- county %>%
    filter(FIPSCODE %in% fips_to_keep)

county_nb <- spdep::poly2nb(
    st_geometry(counties_keep)
)

county_lw <- spdep::nb2listw(
    county_nb, style="B", zero.policy=TRUE
)

neighbours_matrix <- spdep::nb2mat(
    county_nb,
    style="B",
    zero.policy=TRUE
)

### Or: Method 2: Nearest Neighbour (to use if we don't have a full counties dataset) ###

county_nn <- knn2nb(
    knearneigh(
        st_centroid(
            st_geometry(
                counties_keep),
            of_largest_polygon=TRUE
        ),
        k=1
    )
)

neighbours_matrix <- spdep::nb2mat(
    county_nn,
    style="W",
    zero.policy=TRUE
)



