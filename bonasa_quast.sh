#!/bin/bash
#SBATCH --job-name=bonasa_quast                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=8                           # CPU core count per task
#SBATCH --mem=24G                                    # Memory per node
#SBATCH --time=03:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

# configure SRA toolkit before running script with 'vdb-config -i'

OUTDIR="/scratch/las80898/bonasa_quast_1"

# If output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

# Change directory into output directory
cd $OUTDIR

# Copy assembly into OUTDIR
cp /home/las80898/bonasa/Bumbellus.assembly.fa $OUTDIR

# Run Quast
quast Bumbellus.assembly.fa -o $OUTDIR --large --glimmer --split-scaffolds --threads 8 