#!/bin/bash
#SBATCH --job-name=popgen_A_2_pca
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=164G
#SBATCH --time=16:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR="/scratch/las80898/bonasa/popgen/LD"
OUTDIR="/scratch/las80898/bonasa/popgen/PCA"

mkdir -p "$OUTDIR"

cd $INDIR

# PLINK2 PCA (use LD-pruned dataset)
plink2 --bfile cohort_LD_pruned \
  --pca 20 \
  --out $OUTDIR/cohort_pca \
  --allow-extra-chr