#!/bin/bash
#SBATCH --job-name=bonasa_read_mapping                      # Job name 
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

# set outdirectory variable
OUTDIR="/home/las80898/bonasa/mapped_reads"

# If output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

# change directory
cd /home/las80898/bonasa/reads/

# map reads to reference with BWA

for R1 in *_1.fastq_trimmed.fastq; do
    # Derive sample name and R2 file
    base="${R1%_1.fastq_trimmed.fastq}"
    R2="${base}_2.fastq_trimmed.fastq"
    bwa mem -t 8 /home/las80898/bonasa/Bumbellus.assembly.fa $R1 $R2 > ${OUTDIR}/${base}.sam
done   

# -R "$rg"
# # Define read group string
   # rg="@RG\\tID:${base}\\tSM:${base}\\tPL:Illumina\\tLB:1\\tPU:1"
