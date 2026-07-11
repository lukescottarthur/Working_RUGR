#!/bin/bash
#SBATCH --job-name=popgen_B_1_pixy
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=16:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

OUTDIR="/scratch/las80898/popgen"

cd $OUTDIR

# for next analyses, add fst and dxy after --stats

pixy --stats pi \
  --vcf cohort_filtered_allsites.vcf.gz \
  --populations pop_file.txt \
  --window_size 10000 \
  --n_cores 4 \
  --output_folder pixy_output