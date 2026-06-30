#!/bin/bash
#SBATCH --job-name=popgen_3_maf
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=2:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR="/scratch/las80898/bonasa/vcf_reads_2"
OUTDIR="/scratch/las80898/popgen"

mkdir -p "$OUTDIR"

cd $INDIR

# split into variant and nonvariant sites
vcftools --gzvcf biallelic_snps.vcf.gz \
  --max-maf 0 \
  --recode --stdout | bgzip -c > $OUTDIR/invariant.vcf.gz

tabix $OUTDIR/invariant.vcf.gz

# MAF filter + genotype rate filter
# NOTE: change --geno to .1 or .05 for my dataset
#plink2 --vcf biallelic_snps.vcf.gz --maf 0.05 --geno 0.5 --hwe 1e-6 --make-pgen --out $OUTDIR/cohort_maf_filtered --allow-extra-chr

plink2 --vcf biallelic_snps.vcf.gz --maf 0.05 --geno 0.5 --hwe 1e-6 --export vcf bgz --out $OUTDIR/cohort_maf_filtered --allow-extra-chr

tabix -p vcf $OUTDIR/cohort_maf_filtered.vcf.gz

cd $OUTDIR

# combine files
bcftools concat \
  --allow-overlaps \
  cohort_maf_filtered.vcf.gz invariant.vcf.gz \
  -O z -o cohort_filtered.vcf.gz