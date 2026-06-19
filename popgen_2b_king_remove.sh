#!/bin/bash
#SBATCH --job-name=popgen_2_king
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=16:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A_%a.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A_%a.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR="/home/las80898/bonasa/vcf_reads_2"
OUTDIR='/home/las80898/bonasa/popgen'

mkdir -p "$OUTDIR"

Remove one individual from each pair exceeding your kinship threshold (typically 2nd degree, >0.0884) before population structure analyses.
# add code to remove pairs