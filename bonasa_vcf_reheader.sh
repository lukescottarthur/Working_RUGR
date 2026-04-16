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

INDIR="/scratch/las80898/bonasa/temp_bcf_reads_3"
OUTDIR="/scratch/las80898/bonasa/reheader_temp_bcf_reads"
mkdir -p "$OUTDIR"

mapfile -t BCF_FILES < <(ls "${INDIR}"/*.bcf.gz | sort)

BCF="${BCF_FILES[$SLURM_ARRAY_TASK_ID]}"
SAMPLE=$(basename "${BCF%_sorted.bcf.gz}")

echo "Processing sample: $SAMPLE (task index: $SLURM_ARRAY_TASK_ID)"

bcftools reheader \
  -h <(bcftools view -h "$BCF" | sed 's/MQ,Number=1,Type=Integer/MQ,Number=1,Type=Float/g') \
  "$BCF" \
  -o "${OUTDIR}/${SAMPLE}.bcf.gz"