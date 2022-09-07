#!/bin/bash

#SBATCH -N 1
#SBATCH -C knl
#SBATCH --qos=regular
#SBATCH -J fit2
#SBATCH --mail-user=bbrusco@lbl.gov
#SBATCH --mail-type=ALL
#SBATCH -t 16:00:00

#OpenMP settings:
export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=true

module load R
source activate r-venv
cd /global/project/projectdirs/m1532/Projects_MVP/geospatial/GeoSpatial_Model/spatial-prediction
R CMD BATCH R/fit_2.r