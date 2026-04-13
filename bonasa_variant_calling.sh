#!/bin/bash
#SBATCH --job-name=bonasa_variant_calling                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=8                           # CPU core count per task
#SBATCH --mem=128G                                    # Memory per node
#SBATCH --time=36:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

OUTDIR="/home/las80898/bonasa/vcf_reads"

# If output directory doesn't exist, create it
if [ ! -d "$OUTDIR" ]; then
    mkdir -p "$OUTDIR"
fi

cd /home/las80898/bonasa/sorted_bam_files

# Compute genotype likelihoods, variant call, and filter (map quality > 60; quality score > 40; mapped reads > 10)
for bam in *.bam; do
  sample="${bam%.bam}"
  tmp=$(mktemp --suffix=.bcf)

  bcftools mpileup -Ou --threads 8 --min-MQ 60 -f /home/las80898/bonasa/Bumbellus.assembly.fa "$bam" \
    > "$tmp"

  bcftools reheader \
    -h <(bcftools view -h "$tmp" | sed 's/Type=Integer/Type=Float/g') \
    "$tmp" \
    | bcftools call --threads 8 -mv -Ou - \
    | bcftools filter -Oz -e 'QUAL<40 || DP<10' \
    > "${OUTDIR}/${sample}.vcf.gz"

  rm -f "$tmp"
done

