#!/bin/bash
#SBATCH --job-name=popgen_A_1_LD
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

INDIR="/scratch/las80898/bonasa/popgen/cohort_files"
OUTDIR="/scratch/las80898/bonasa/popgen/LD"

cd $INDIR

# LD pruning (window=50kb, step=10 SNPs, r²<0.1 for PCA/ADMIXTURE)
# Use r²<0.3–0.5 for GWAS-adjacent analyses
plink2 --vcf cohort_filtered_allsites.vcf.gz \
  --set-all-var-ids '@:#:$r:$a' \
  --new-id-max-allele-len 500 \
  --rm-dup exclude-all \
  --indep-pairwise 50 10 0.1 \
  --snps-only just-acgt \
  --max-alleles 2 \
  --out $OUTDIR/pruned_snps \
  --allow-extra-chr

# extravtion step
  plink2 --vcf cohort_filtered_allsites.vcf.gz \
  --set-all-var-ids '@:#:$r:$a' \
  --new-id-max-allele-len 500 \
  --snps-only just-acgt \
  --max-alleles 2 \
  --rm-dup exclude-all \
  --extract $OUTDIR/pruned_snps.prune.in \
  --make-bed \
  --out cohort_LD_pruned \
  --allow-extra-chr
