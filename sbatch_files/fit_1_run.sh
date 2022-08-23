#!/bin/bash

#SBATCH -N 1
#SBATCH -C knl
#SBATCH --qos=regular
#SBATCH -J spatial_bayesian_prediction
#SBATCH --mail-user=bbrusco@lbl.gov
#SBATCH --mail-type=ALL
#SBATCH -t 01:30:00

#OpenMP settings:
export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=true

module load R
cd /global/u2/b/bbrusco/spatial-prediction
source activate r-venv
R CMD BATCH R/fit_1.r