This document keeps track of which data files are used in the fitted models and where the data files are stored.

The models fitted here use mainly two data files:

* ACS yearly dataset with covariates relating to social determinants of health (e.g. TOTAL HOUSEHOLD size, or PCT VA College).
  Full dataset for years 2016, 2017, 2018.
  
  Folder path:
  
  ```
  ~/bbrusco/spatial-prediction/data/raw/sdoh/
  ```
  
  The predictors of interest selected via Hierarchical Clustering (features of highest importance).
  
* Yearly VA Suicide Deaths datasets

  Folder path:
  
  ```
  ~/bbrusco/spatial-prediction/data/raw/suicide/
  ```
  
These files are combined (using the code in `R/0_merge_data.r`) and the resulting dataset is saved in `~/bbrusco/spatial-prediction/data/processed/combined.csv`

  
Other files needed to run the model:

  
 * Census demographic information (in particular, county population) 
 
  File path:
  
  ```
  ~/bbrusco/spatial-prediction/data/raw/demo/2020-demographic-info.csv
  ```
  
 * Spatial information (shapefiles):

  ```
  ~/bbrusco/spatial-prediction/data/shapefile
  ```


Note:

The models can be fit using more years by adding files to the corresponding folders as `{year}.csv`.

  





