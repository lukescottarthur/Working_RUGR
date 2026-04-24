#!/bin/bash
#SBATCH --job-name=radish_sim1
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=256gb
#SBATCH --time=12:00:00
#SBATCH --error=/home/las80898/GENE8940_parallel_2/radishsim1.%j.err
#SBATCH --output=/home/las80898/GENE8940_parallel_2/radishsim1.%j.out
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=END,FAIL

# conda create -n landscape_env
# conda activate landscape_env
# conda install conda-forge::r-base
# conda install -c conda-forge r-terra
# conda install -c conda-forge r-spatialeco
# conda install -c conda-forge r-codetools
# conda install -c conda-forge r-radish
# conda install raster
# conda install r-readxl
# conda install r-adegenet
conda install r-ggplot2
# conda install r-sp r-GeNetIt
# conda install r-radish

# activate R environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate landscape_env

#set output directory variable
OUTDIR="/scratch/las80898/bonasa/radish_sim1"

#if output directory doesn't exist, create it
if [ ! -d "$OUTDIR" ]
then
    mkdir -p "$OUTDIR"
fi

# run R script
R --no-save < /home/las80898/GENE8940_parallel_2/radish_sim1.r
