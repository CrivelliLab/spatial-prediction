library(tidyverse)

## Utils

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

