#!/bin/bash
#SBATCH --job-name=popgen_A_3_admixture
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=16:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

OUTDIR="/scratch/las80898/popgen"

cd $OUTDIR


# BCFtools ROH (HMM-based, best for WGS)
bcftools roh --AF-tag AF -O r -o roh_output.txt filtered.vcf.gz

#Calculate F_ROH as: sum of ROH length (>1Mb) / total autosomal genome length
