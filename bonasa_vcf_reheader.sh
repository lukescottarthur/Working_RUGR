#!/bin/bash
#SBATCH --job-name=bonasa_vcf_reheader                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=4                           # CPU core count per task
#SBATCH --mem=16G                                    # Memory per node
#SBATCH --time=36:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

OUTDIR="/scratch/las80898/bonasa/reheader_temp_bcf_reads"

# If output directory doesn't exist, create it
if [ ! -d "$OUTDIR" ]; then
    mkdir -p "$OUTDIR"
fi

cd /scratch/las80898/bonasa/temp_bcf_reads_3

# change to MQ=Float
for bcf in *.bcf.gz; do
  sample="${bcf%.bcf.gz}"

  bcftools reheader \
    -h <(bcftools view -h "$bcf" | sed 's/MQ,Number=1,Type=Integer/MQ,Number=1,Type=Float/g') \
    "$bcf" \
    -o "${OUTDIR}/${sample}.bcf.gz"
done