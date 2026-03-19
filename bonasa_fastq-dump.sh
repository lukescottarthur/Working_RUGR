#!/bin/bash
#SBATCH --job-name=bonasa_fastq-dump                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=6                           # CPU core count per task
#SBATCH --mem=16G                                    # Memory per node
#SBATCH --time=04:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# default threads=6 for fastq-dump.

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

OUTDIR="/home/las80898/bonasa/reads"

# Change directory into output directory
cd $OUTDIR

# cycle through directories and use vdb-validate
for SRR in $OUTDIR
do
fastq-dump --split-3 SRR*
done