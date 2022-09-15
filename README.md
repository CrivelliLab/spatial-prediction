# spatial-prediction

For details on the data used, the models fit, and description of the model outputs, see the `.\docs\` folder.

**Goal**: Based on historical data on suicide deaths and covariates representing social determinants of health, we want to predict counties with high suicide risk.


### Creating the Virtual Environment

To run on Cori, we create a virtual environment with the required packages as outlined in the documentation 

```
nersc$ module load R/4.1.2-conda-4.11.0
nersc$ source activate r-env-sp
nersc$ mamba install -c conda-forge r r-essentials spdep leaflet sf tidyverse caret
```

The two packages used for Bayesian Hierarchical Models with Temporal and Spatial random effects are not on conda - but they can be installed as follows.

```
nersc$ R
> install.packages("CARBayesST", lib='~/.R/srclib/r-venv')
> install.packages("CARBayes", lib='~/.R/srclib/r-venv')
# Optional, for rendering.
> install.packages("geojsonio", lib='~/.R/srclib/r-venv')
```


### Fitting the models

1. Create the full dataset needed (`R/0_merge_data.r`) 
    This file can be used to merge the datasets with the social determinants of health variables and the dataset with the suicide death count by county (joined using FIPS code).


2. Create neighbours matrix as outlined in (`R/create_neighbours_matrix.R`)
    
    
    
3. Model fit :

* `R/fit_1.r` (random temporal effects and random spatial effects)

To run the model: 

```
nersc$ sbatch sbatch_files/fit_1_run.sh 
```

to run a slurm job for the models.

Similarly for Model 2

* `R/fit_2.r` (linear -fixed effects time (year) and random spatial effects)

To run the model : 

```
nersc$ sbatch_files/fit_2_run.sh
```

And for model 3


* `R/fit_3.r` (random spatial and temporal effects, AR2)

To run the model : 

```
nersc$ sbatch_files/fit_2_run.sh
```
