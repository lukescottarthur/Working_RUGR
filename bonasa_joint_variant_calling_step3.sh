#!/bin/bash
#SBATCH --job-name=joint_variant_calling_step3
#SBATCH --partition=batch
#SBATCH --ntasks=1                          # Each array task runs as 1 process
#SBATCH --cpus-per-task=4                   # 4 CPUs per sample (see notes)
#SBATCH --mem=16G                           # Memory per array task
#SBATCH --time=8:00:00                     # Per-task time limit
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

cd /scratch/las80898/bonasa/vcf_files

## STEP 3: concatenate chunks into final vcf
bcftools concat -a -Oz -o cohort_allsites.vcf.gz \
  $(ls -v /scratch/las80898/bonasa/vcf_files/regions_*.vcf.gz)
  
bcftools index -t cohort_allsites.vcf.gz