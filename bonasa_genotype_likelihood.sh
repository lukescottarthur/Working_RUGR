#!/bin/bash
#SBATCH --job-name=bonasa_genotype_likelihood
#SBATCH --partition=batch
#SBATCH --array=0-53                        # One task per BAM file (54 total)
#SBATCH --ntasks=1                          # Each array task runs as 1 process
#SBATCH --cpus-per-task=4                   # 4 CPUs per sample (see notes)
#SBATCH --mem=16G                           # Memory per array task
#SBATCH --time=48:00:00                     # Per-task time limit
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A_%a.out   # %A=jobID, %a=arrayIndex
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A_%a.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

OUTDIR="/scratch/las80898/bonasa/temp_bcf_reads_3"
BAMDIR="/home/las80898/bonasa/sorted_bam_files"

mkdir -p "$OUTDIR"

# Build an array of all BAM files, then select one by SLURM task index
mapfile -t BAM_FILES < <(ls "${BAMDIR}"/*.bam | sort)

BAM="${BAM_FILES[$SLURM_ARRAY_TASK_ID]}"
SAMPLE=$(basename "${BAM%.bam}")

echo "Processing sample: $SAMPLE (task index: $SLURM_ARRAY_TASK_ID)"

bcftools mpileup \
    -Ou \
    --threads $SLURM_CPUS_PER_TASK \
    --min-MQ 60 \
    -f /home/las80898/bonasa/Bumbellus.assembly.fa \
    "$BAM" \
    > "${OUTDIR}/${SAMPLE}.bcf.gz"