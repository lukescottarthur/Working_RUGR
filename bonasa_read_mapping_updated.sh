#!/bin/bash
#SBATCH --job-name=bonasa_read_mapping_updated
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=72:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

set -eo pipefail

REF=/scratch/las80898/bonasa/Bumbellus.assembly.fa
INDIR=/work/hblab/grouse_georgia_fastp
OUTDIR=/work/hblab/grouse_georgia_mapped_reads

mkdir -p "$OUTDIR"

# Confirm the reference is indexed before starting (fails fast with a clear message)
for ext in amb ann bwt pac sa; do
    if [[ ! -f "${REF}.${ext}" ]]; then
        echo "ERROR: reference not indexed (missing ${REF}.${ext}). Run 'bwa index ${REF}' first." >&2
        exit 1
    fi
done

cd "$INDIR"

for R1 in *.1.trimmed.fq.gz; do
    base="${R1%.1.trimmed.fq.gz}"
    R2="${base}.2.trimmed.fq.gz"

    if [[ ! -f "$R2" ]]; then
        echo "Missing $R2 for sample $base, skipping" >&2
        continue
    fi

    echo "Mapping sample $base"
    bwa mem -t 8 \
        -R "@RG\tID:${base}\tSM:${base}\tLB:${base}\tPL:ILLUMINA" \
        "$REF" "$R1" "$R2" | \
      samtools fixmate -m -u -@ 2 - - | \
      samtools sort -u -@ 4 -m 2G - | \
      samtools markdup -@ 2 - -s "${OUTDIR}/${base}.markdup.bam"

    samtools index "${OUTDIR}/${base}.markdup.bam"
done