#!/bin/bash
#SBATCH --job-name=popgen_2_relatedness
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=256G
#SBATCH --time=16:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR='/scratch/las80898/bonasa/vcf_files'
OUTDIR='/scratch/las80898/bonasa/popgen/king_table'

mkdir -p "$OUTDIR"

cd $INDIR

#Remove one individual from each pair exceeding your kinship threshold (typically 2nd degree, >0.0884) before population structure analyses.

plink2 \
  --vcf cohort_allsites.vcf.gz \
  --make-king-table \
  --allow-extra-chr \
  --king-table-filter 0.0884 \
  --threads ${SLURM_CPUS_PER_TASK} \
  --memory 250000 \
  --out $OUTDIR/results_2