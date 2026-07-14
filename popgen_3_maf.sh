#!/bin/bash
#SBATCH --job-name=popgen_3_maf
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

INDIR="/scratch/las80898/bonasa/vcf_files"
OUTDIR="/scratch/las80898/popgen"

mkdir -p "$OUTDIR"

cd $INDIR

# split into variant and nonvariant sites
bcftools view \
  --threads ${SLURM_CPUS_PER_TASK} \
  -i 'AC==0 || AC==AN' \
  cohort_allsites_2.vcf.gz \
  -O z -o $OUTDIR/invariant_2.vcf.gz

tabix $OUTDIR/invariant_2.vcf.gz
tabix $OUTDIR/cohort_allsites_2.vcf.gz

# MAF filter + genotype rate filter
# NOTE: change --geno to .1 or .05 for my dataset
#plink2 --vcf cohort_allsites.vcf.gz --maf 0.05 --geno 0.5 --hwe 1e-6 --make-pgen --out $OUTDIR/cohort_maf_filtered_allsites --allow-extra-chr

plink2 \
  --vcf cohort_allsites_2.vcf.gz \
  --maf 0.05 \
  --geno 0.5 \
  --hwe 1e-6 \
  --export vcf bgz \
  --threads ${SLURM_CPUS_PER_TASK} \
  --memory 250000 \
  --out $OUTDIR/cohort_maf_filtered_allsites_2 \
  --allow-extra-chr

tabix -p vcf $OUTDIR/cohort_maf_filtered_allsites_2.vcf.gz

cd $OUTDIR

# combine files
bcftools concat \
  --allow-overlaps \
  cohort_maf_filtered_allsites_2.vcf.gz invariant_2.vcf.gz \
  -O z -o cohort_filtered_allsites.vcf.gz

tabix -p vcf cohort_filtered_allsites.vcf.gz