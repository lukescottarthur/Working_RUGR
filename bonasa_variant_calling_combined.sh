#!/bin/bash
#SBATCH --job-name=bonasa_variant_calling
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
conda activate bonasa_env


OUTDIR="/home/las80898/bonasa/vcf_files"
BAMDIR="/home/las80898/bonasa/sorted_bam_files"

mkdir -p "$OUTDIR"

# Build an array of all BAM files, then select one by SLURM task index
mapfile -t BAM_FILES < <(ls "${BAMDIR}"/*.bam | sort)
BAM="${BAM_FILES[$SLURM_ARRAY_TASK_ID]}"
SAMPLE=$(basename "${BAM%.bam}")

# Genotype likelihood, Variant call and filter (MQ > 60; quality score > 40; mapped reads > 10)

bcftools mpileup \
    -Ou \
    --threads $SLURM_CPUS_PER_TASK \
    --min-MQ 60 \
    -f /home/las80898/bonasa/Bumbellus.assembly.fa \
    "$BAM" \
  | bcftools call --threads 4 -mv -Ou \
  | bcftools filter -Oz -e 'QUAL<40 || DP<10' \
  > "${OUTDIR}/${SAMPLE}.vcf.gz"

  # Index the output for downstream tools
bcftools index --tbi "${OUTDIR}/${SAMPLE}.vcf.gz"
