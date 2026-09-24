#!/bin/bash
#SBATCH --job-name=reads_integrity_check
#SBATCH --output=download_%j.log
#SBATCH --time=2:00:00   # Generous time limit for large WGS files
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G          # Low memory footprint needed for downloading
#SBATCH --partition=batch
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=END,FAIL


# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env


for file in /work/hblab/grouse_georgia_reads/*; do
    gzip -t $file
done