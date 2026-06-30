#!/bin/bash
#SBATCH --job-name=popgen_A_3_admixture
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

# Run for K=1 to K=10, use cross-validation to select best K
for K in $(seq 1 10); do
  admixture --cv cohort_LD_pruned.bed $K | tee log_K${K}.out
done

# Extract CV errors to select optimal K
grep "CV error" log_K*.out | sort -t: -k2 -n
