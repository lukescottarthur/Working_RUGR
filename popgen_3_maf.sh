#!/bin/bash
#SBATCH --job-name=popgen_3_maf
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

INDIR="/home/las80898/bonasa/vcf_reads_2"
OUTDIR='/home/las80898/bonasa/popgen/pgen_files'

mkdir -p "$OUTDIR"

cd $INDIR

# MAF filter + genotype rate filter
plink2 --vcf biallelic_snps.vcf.gz --maf 0.05 --geno 0.1 --hwe 1e-6 --make-pgen --out $OUTDIR/cohort_maf_filtered --allow-extra-chr