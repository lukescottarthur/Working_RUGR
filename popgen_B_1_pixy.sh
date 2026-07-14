#!/bin/bash
#SBATCH --job-name=popgen_B_1_pixy
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=256G
#SBATCH --time=24:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR="/scratch/las80898/bonasa/popgen/cohort_files"
OUTDIR="scratch/las80898/bonasa/popgen/pixy"

cd $INDIR

# for next analyses, add fst and dxy after --stats

pixy --stats pi \
  --vcf cohort_filtered_allsites.vcf.gz \
  --populations pop_file.txt \
  --window_size 10000 \
  --n_cores 8 \
  --output_folder $OUTDIR/pixy_output