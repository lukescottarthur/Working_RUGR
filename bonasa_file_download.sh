#!/bin/bash
#SBATCH --job-name=bonasa_file_download                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=16                           # CPU core count per task
#SBATCH --mem=24G                                    # Memory per node
#SBATCH --time=08:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

# configure SRA toolkit before running script with 'vdb-config -i'

OUTDIR="/home/las80898/bonasa/reads"

# If output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

# Download reads
prefetch -O $OUTDIR --option-file bonasa_SRR.numbers

