#!/bin/bash
#SBATCH --job-name=bonasa_fastp
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=16G
#SBATCH --time=016:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

# Stop at the first error (set after conda activation, which can trip on unset variables)
set -eo pipefail

INDIR=/work/hblab/grouse_georgia_reads
OUTDIR=/work/hblab/grouse_georgia_fastp
mkdir -p "$OUTDIR"

for file1 in "$INDIR"/*.1.fq.gz; do
    sample=$(basename "$file1" .1.fq.gz)
    file2="$INDIR/${sample}.2.fq.gz"

    if [[ ! -f "$file2" ]]; then
        echo "Missing reverse read for sample $sample, skipping" >&2
        continue
    fi

    echo "Trimming sample $sample"
    fastp --thread 6 \
        -i "$file1" -I "$file2" \
        -o "$OUTDIR/${sample}.1.trimmed.fq.gz" -O "$OUTDIR/${sample}.2.trimmed.fq.gz" \
        --unpaired1 "$OUTDIR/${sample}.unpaired.1.fq.gz" \
        --unpaired2 "$OUTDIR/${sample}.unpaired.2.fq.gz" \
        --detect_adapter_for_pe \
        -h "$OUTDIR/${sample}.fastp.html" \
        -j "$OUTDIR/${sample}.fastp.json"
done