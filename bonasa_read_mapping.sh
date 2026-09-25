#!/bin/bash
#SBATCH --job-name=bonasa_read_mapping                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=8                           # CPU core count per task
#SBATCH --mem=128G                                    # Memory per node
#SBATCH --time=56:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

# Stop at the first error (set after conda activation, which can trip on unset variables)
set -eo pipefail

INDIR=/work/hblab/grouse_georgia_fastp
OUTDIR=/work/hblab/grouse_georgia_mapped_reads

# If output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

# change directory
cd $INDIR

# map reads to reference with BWA

for R1 in *.1.trimmed.fq.gz; do
    # Derive sample name and R2 file
    base="${R1%.1.trimmed.fq.gz}"
    R2="${base}.2.trimmed.fq.gz"
    bwa mem -t 8 /scratch/las80898/bonasa/Bumbellus.assembly.fa $R1 $R2 > ${OUTDIR}/${base}.sam
done   
