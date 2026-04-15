#!/bin/bash
#SBATCH --job-name=bonasa_variant_calling                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=24                           # CPU core count per task
#SBATCH --mem=256G                                    # Memory per node
#SBATCH --time=94:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

OUTDIR="/scratch/las80898/bonasa/temp_bcf_reads_2"

# If output directory doesn't exist, create it
if [ ! -d "$OUTDIR" ]; then
    mkdir -p "$OUTDIR"
fi

cd /home/las80898/bonasa/sorted_bam_files

# Compute genotype likelihoods with MQ > 60
for bam in *.bam; do
  sample="${bam%.bam}"

  bcftools mpileup -Ou --threads 24 --min-MQ 60 -f /home/las80898/bonasa/Bumbellus.assembly.fa "$bam" > "${OUTDIR}/${sample}.bcf.gz"
  done

