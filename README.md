# spatial-prediction


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
> install.packages("CARBayes", lib='~/.R/srclib/r-venv')
> install.packages("CARBayesST", lib='~/.R/srclib/r-venv')
# Optional, for rendering.
> install.packages("geojsonio", lib='~/.R/srclib/r-venv')
```


### Fitting the models

1. Create the full dataset needed (R/0_merge_data.r) 
2. Create neighbours matrix as outlined in (R/create_neighbours_matrix.R)
3. Model fit : either fit_1.r (random temporal effects) or fit_2.r (fixed temporal effects)
4. sbatch_files/fit_1_run.sh to run a slurm job for the models.

