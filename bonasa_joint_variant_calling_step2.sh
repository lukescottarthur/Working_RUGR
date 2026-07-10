#!/bin/bash
#SBATCH --job-name=bonasa_joint_calling
#SBATCH --partition=batch
#SBATCH --array=0-21
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A_%a.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A_%a.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate bonasa_env

set -euo pipefail

OUTDIR="/scratch/las80898/bonasa/vcf_files"
BAMDIR="/scratch/las80898/bonasa/sorted_bam_files"
REGIONDIR="/scratch/las80898/bonasa/regions"
REF="/scratch/las80898/bonasa/Bumbellus.assembly.fa"
mkdir -p "$OUTDIR"

mapfile -t REGION_FILES < <(find "${REGIONDIR}" -maxdepth 1 -name "regions_*.txt" | sort -V)
REGION_FILE="${REGION_FILES[$SLURM_ARRAY_TASK_ID]}"
CHUNK_NAME=$(basename "${REGION_FILE%.txt}")

if [[ -z "$REGION_FILE" ]]; then
    echo "No region file for task index $SLURM_ARRAY_TASK_ID — exiting."
    exit 1
fi

# all BAMs, called jointly, restricted to this chunk's regions
mapfile -t BAMS < <(find "${BAMDIR}" -maxdepth 1 -name "*.bam" | sort)

bcftools mpileup \
    -Ou \
    --threads $SLURM_CPUS_PER_TASK \
    --min-MQ 60 \
    -a FORMAT/DP,FORMAT/AD \
    -f "$REF" \
    -R "$REGION_FILE" \
    "${BAMS[@]}" \
  | bcftools call --threads $SLURM_CPUS_PER_TASK -m -Ou \
  | bcftools filter -Oz -e '(ALT!="." && QUAL<40)' \
  > "${OUTDIR}/${CHUNK_NAME}.vcf.gz"

bcftools index --tbi "${OUTDIR}/${CHUNK_NAME}.vcf.gz"
