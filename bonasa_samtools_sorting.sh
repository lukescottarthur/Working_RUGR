#!/bin/bash
#SBATCH --job-name=bonasa_samtools_sorting                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=6                           # CPU core count per task
#SBATCH --mem=16G                                    # Memory per node
#SBATCH --time=012:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

convert to BAM with SAMtools, sort with SAMtools, and output as sorted BAM file

#| samtools sort -O BAM --threads 6 - > *_sorted.bam
# index bam files
#for file in /home/las80898/bonasa/reads/; do
#    samtools index --threads 6 *_sorted.bam
#    done