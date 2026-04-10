#!/bin/bash
#SBATCH --job-name=bonasa_fastp                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=6                           # CPU core count per task
#SBATCH --mem=16G                                    # Memory per node
#SBATCH --time=08:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

# Change directory into input directory
cd /home/las80898/bonasa/reads

for file1 in /home/las80898/bonasa/reads/*_1.fastq; do
    file2=${file1%%_1.fastq}_2.fastq
    fastp --thread 6 -D -i ${file1} -I ${file2} -o ${file1}_trimmed.fastq -O ${file2}_trimmed.fastq --unpaired1 ${file1}.unpaired.trimmed.fastq --unpaired2 ${file2}.unpaired.trimmed.fastq
done   