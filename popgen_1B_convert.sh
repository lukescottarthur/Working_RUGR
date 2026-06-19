#!/bin/bash
#SBATCH --job-name=popgen_1B_convert
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=16:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A_%a.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A_%a.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR="/home/las80898/bonasa/vcf_reads_2"
OUTDIR='/home/las80898/bonasa/popgen'

mkdir -p "$OUTDIR"

cd $INDIR

# make index file 
bcftools index -t biallelic_snps.vcf.gz

 # Convert to PLINK format first
plink2 --vcf biallelic_snps.vcf.gz --make-bed --out $OUTDIR/cohort --allow-extra-chr

