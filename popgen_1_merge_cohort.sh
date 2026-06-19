#!/bin/bash
#SBATCH --job-name=popgen_1_merge_cohort
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

OUTDIR="/home/las80898/bonasa/vcf_reads_2"

cd $OUTDIR

# Merge per-sample vcf.gz files into a cohort VCF
bcftools merge --force-samples -O z -o cohort.vcf.gz *.vcf.gz
bcftools index -t cohort.vcf.gz

# Keep only biallelic SNPs
bcftools view -O z -o biallelic_snps.vcf.gz -m2 -M2 -v snps cohort.vcf.gz