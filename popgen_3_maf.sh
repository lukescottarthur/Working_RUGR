#!/bin/bash
#SBATCH --job-name=popgen_3_maf
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=256G
#SBATCH --time=24:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR="/scratch/las80898/bonasa/vcf_files"
OUTDIR="/scratch/las80898/bonasa/popgen/cohort_files"
mkdir -p "$OUTDIR"

cd $INDIR

# invariant sites - filter directly on ALT="." (matches what pixy checks)
bcftools view \
  --threads ${SLURM_CPUS_PER_TASK} \
  -i 'ALT="."' \
  cohort_allsites.vcf.gz \
  -O z -o $OUTDIR/invariant_2.vcf.gz

tabix -p vcf $OUTDIR/invariant_2.vcf.gz

echo "=== Check: invariant sites extracted ==="
INVARIANT_COUNT=$(zcat $OUTDIR/invariant_2.vcf.gz | grep -vc "^#")
echo "Invariant sites in invariant_2.vcf.gz: ${INVARIANT_COUNT}"
if [[ "$INVARIANT_COUNT" -eq 0 ]]; then
    echo "ERROR: No invariant sites found — aborting before downstream steps." >&2
    exit 1
fi

# MAF filter + genotype rate filter
plink2 \
  --vcf cohort_allsites.vcf.gz \
  --maf 0.05 \
  --geno 0.1 \
  --hwe 1e-6 0.001 \
  --export vcf bgz \
  --threads ${SLURM_CPUS_PER_TASK} \
  --memory 250000 \
  --out $OUTDIR/cohort_maf_filtered_allsites \
  --allow-extra-chr

tabix -p vcf $OUTDIR/cohort_maf_filtered_allsites.vcf.gz

cd $OUTDIR

# combine files - concat does NOT sort, so pipe into bcftools sort
bcftools concat --allow-overlaps \
  cohort_maf_filtered_allsites.vcf.gz invariant_2.vcf.gz \
  -O u \
| bcftools sort -O z -o cohort_filtered_allsites.vcf.gz -T $OUTDIR/tmp_sort

tabix -p vcf cohort_filtered_allsites.vcf.gz

echo "=== Check: final merged VCF composition ==="
TOTAL_COUNT=$(zcat cohort_filtered_allsites.vcf.gz | grep -vc "^#")
FINAL_INVARIANT_COUNT=$(zcat cohort_filtered_allsites.vcf.gz | grep -v "^#" | awk '$5=="."' | wc -l)
FINAL_VARIANT_COUNT=$((TOTAL_COUNT - FINAL_INVARIANT_COUNT))

echo "Total sites:            ${TOTAL_COUNT}"
echo "Invariant sites (ALT=.): ${FINAL_INVARIANT_COUNT}"
echo "Variant sites:           ${FINAL_VARIANT_COUNT}"

if [[ "$FINAL_INVARIANT_COUNT" -eq 0 ]]; then
    echo "ERROR: Final merged VCF has no invariant sites — pixy will fail." >&2
    exit 1
fi
if [[ "$FINAL_VARIANT_COUNT" -eq 0 ]]; then
    echo "WARNING: Final merged VCF has no variant sites — check MAF/geno/HWE thresholds." >&2
fi

echo "=== Check: tabix re-validation ==="
if tabix -f -p vcf cohort_filtered_allsites.vcf.gz; then
    echo "tabix confirms file is properly sorted and indexed."
else
    echo "ERROR: tabix indexing failed — file is not properly sorted." >&2
    exit 1
fi
