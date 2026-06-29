#!/bin/bash
#SBATCH --job-name=popgen_4_vcf_conversion
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

INDIR="/home/las80898/bonasa/popgen/pgen_files"
OUTDIR="/home/las80898/bonasa/popgen/pixy"

mkdir -p "$OUTDIR"

cd $INDIR

plink2 --pfile cohort_maf_filtered --export vcf --out $OUTDIR/cohort_maf_filtered

cd $OUTDIR

bgzip cohort_maf_filtered.vcf
tabix -p vcf cohort_maf_filtered.vcf.gz