setwd("/global/u2/b/bbrusco/spatial-prediction")
library(tidyverse)
library(sf)

METHOD <- "knn"

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


counties_keep <- county %>%
    filter(FIPSCODE %in% fips_to_keep)
#length(fips_to_keep)
#1931


### Method 1: Binary Matrix ###

if(METHOD=="binary"){
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
}

### Or: Method 2: Nearest Neighbour (to use if we don't have a full counties dataset) ###
else if(METHOD=="knn"){
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


    # do to imprecisions, matrix is not symmetric as it should be.
    # Note: this is a reason why binary matrix is preferable.

    county_nn.sym <- make.sym.nb(county_nn)

    neighbours_matrix <- spdep::nb2mat(
        county_nn.sym,
        style="W"
    )
    # due to numerical inconsitencies original matrix is not symmetric even if neighbours list is symmetric. 
    # Therefore, force symmetric.
    # Again, this should not be necessary with Binary matrix.

    neighbours_matrix <- as.matrix(Matrix::forceSymmetric(neighbours_matrix))


}

else{
    "METHOD must be `knn` or `binary`"
}

# save matrix.
saveRDS(
    neighbours_matrix,
    file = "data/processed/neighbours_matrix.rds"
)
    
# checks
# sum(rowSums(neighbours_matrix)) # should be same as fips_to_keep
# min(rowSums(neighbours_matrix)) # should be 1
# max(rowSums(neighbours_matrix)) # should be 1


