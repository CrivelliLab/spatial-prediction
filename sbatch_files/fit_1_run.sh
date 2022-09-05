#!/bin/bash

#SBATCH -N 1
#SBATCH -C knl
#SBATCH --qos=regular
#SBATCH -J fit1
#SBATCH --mail-user=bbrusco@lbl.gov
#SBATCH --mail-type=ALL
#SBATCH -t 18:30:00

module load R
cd /global/u2/b/bbrusco/spatial-prediction
source activate r-venv
R CMD BATCH R/fit_1.r