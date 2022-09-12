#!/bin/bash

#SBATCH -N 1
#SBATCH -C knl
#SBATCH --qos=regular
#SBATCH -J fit3
#SBATCH --mail-user=bbrusco@lbl.gov
#SBATCH --mail-type=ALL
#SBATCH -t 18:30:00

module load R
cd /global/project/projectdirs/m1532/Projects_MVP/geospatial/GeoSpatial_Model/spatial-prediction
source activate r-venv
R CMD BATCH R/fit_3.r