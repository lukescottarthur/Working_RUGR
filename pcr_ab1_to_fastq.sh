#!/bin/bash
#SBATCH --job-name=pcr_ab1_convert                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=1                           # CPU core count per task
#SBATCH --mem=24G                                    # Memory per node
#SBATCH --time=01:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

# configure SRA toolkit before running script with 'vdb-config -i'

OUTDIR="/home/las80898/bonasa/pcr_reads/cytb_1_fastq"

# If output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

# Change directory
cd /home/las80898/bonasa/pcr_reads/cytb_1_ab1

for file in *.ab1; do
sample="${file%.ab1}"

    seqret -sformat abi -osformat fastq -auto -stdout -sequence "$file" > "${OUTDIR}/${sample}.fastq"
done   
