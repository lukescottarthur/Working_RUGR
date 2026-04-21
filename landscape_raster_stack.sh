#!/bin/bash
#SBATCH --job-name=landscape_raster_stack
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64gb
#SBATCH --time=12:00:00
#SBATCH --error=/home/las80898/GENE8940_parallel_2/rasterstackprep.%j.err
#SBATCH --output=/home/las80898/GENE8940_parallel_2/rasterstackprep.%j.out
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# activate R environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate test_env

#set output directory variable
OUTDIR="/scratch/las80898/bonasa/"                 

#if output directory doesn't exist, create it
if [ ! -d "$OUTDIR" ]
then
    mkdir -p "$OUTDIR"
fi

# run R script
R --no-save < /home/las80898/GENE8940_parallel_2/landscape_raster_stack.r
