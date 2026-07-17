#!/bin/bash
#SBATCH --job-name=popgen_A_3_admixture
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=164G
#SBATCH --time=48:00:00
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
OUTDIR="/scratch/las80898/bonasa/popgen"

cd $INDIR

# make backup bim and assign unique chromosome integers prior to running
#cp cohort_LD_pruned.bim cohort_LD_pruned.bim.bak

#awk 'BEGIN{OFS="\t"} 
#{
#  if (!($1 in map)) { map[$1] = ++n }
#  $1 = map[$1]
#  print
#}' cohort_LD_pruned.bim.bak > cohort_LD_pruned.bim


# Run for K=1 to K=10, use cross-validation to select best K
for K in $(seq 1 10); do
  admixture --cv cohort_LD_pruned.bed $K | tee log_K${K}.out
done

# Extract CV errors to select optimal K
grep "CV error" log_K*.out | sort -t: -k2 -n
