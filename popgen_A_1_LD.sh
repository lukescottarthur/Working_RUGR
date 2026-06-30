#!/bin/bash
#SBATCH --job-name=popgen_A_1_LD
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

# LD pruning (window=50kb, step=10 SNPs, r²<0.1 for PCA/ADMIXTURE)
# Use r²<0.3–0.5 for GWAS-adjacent analyses
plink2 --bfile cohort_maf_filtered \
  --indep-pairwise 50 10 0.1 \
  --out pruned_snps \
  --allow-extra-chr

plink2 --bfile cohort_maf_filtered \
  --extract pruned_snps.prune.in \
  --make-bed \
  --out cohort_LD_pruned \
  --allow-extra-chr