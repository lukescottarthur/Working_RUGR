#!/bin/bash
#SBATCH --job-name=bonasa_vcf_reheader
#SBATCH --partition=batch
#SBATCH --array=0-53
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=36:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A_%a.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A_%a.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

INDIR="/home/las80898/bonasa/vcf_reads"
OUTDIR="/home/las80898/bonasa/vcf_reads_2"
mkdir -p "$OUTDIR"

mapfile -t VCF_FILES < <(ls "${INDIR}"/*.vcf.gz | sort)
VCF="${VCF_FILES[$SLURM_ARRAY_TASK_ID]}"
SAMPLE=$(basename "${VCF%.vcf.gz}")

bcftools reheader \
  -h <(bcftools view -h "$VCF" | sed 's/MQ,Number=1,Type=Integer/MQ,Number=1,Type=Float/g') \
  "$VCF" \
  -o "${OUTDIR}/${SAMPLE}.vcf.gz"