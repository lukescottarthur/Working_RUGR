#!/bin/bash
#SBATCH --job-name=bonasa_snp_pruning
#SBATCH --partition=batch
#SBATCH --array=0-53
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A_%a.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A_%a.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR="/home/las80898/bonasa/vcf_reads"
OUTDIR="/home/las80898/bonasa/pruned_reads"

mkdir -p "$OUTDIR"

# Build an array of all vcf files and select one per SLURM task
mapfile -t VCF_FILES < <(ls "${INDIR}"/*.vcf.gz)
VCF="${VCF_FILES[$SLURM_ARRAY_TASK_ID]}"
SAMPLE=$(basename "$VCF" .vcf.gz)

# SNP pruning for LD and MAF
# needs to be edited
plink --bfile input_data \
      --maf 0.01 \
      --indep-pairwise 50 5 0.2 \
      --out pruned_snps   