#!/bin/bash
#SBATCH --job-name=bonasa_samtools_sorting                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=8                           # CPU core count per task
#SBATCH --mem=128G                                    # Memory per node
#SBATCH --time=024:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

# set outdirectory variable
OUTDIR="/home/las80898/bonasa/sorted_bam_files"

# If output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

cd /home/las80898/bonasa/mapped_reads2

# sort and convert to BAM
for file in *.sam; do
    base="${file%.sam}"
    samtools sort -O BAM --threads 8 $file > ${OUTDIR}/${base}_sorted.bam
done
