#!/bin/bash
#SBATCH --job-name=bonasa_file_download                      # Job name 
#SBATCH --partition=batch                           # Partition name 
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=8                           # CPU core count per task
#SBATCH --mem=24G                                    # Memory per node
#SBATCH --time=03:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%j.out  
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%j.error 
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail
#SBATCH --mail-type=BEGIN,END,FAIL                        # Mail events 

# Load conda environment (SRA toolkit, BWA, samtools, bcftools)
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








# Map reads to reference and store in bam format
bwa mem -t 6 Bumbellus.assembly.fa SRR8082143_1.fastq SRR8082143_2.fastq | samtools sort -O BAM --threads 6 - > SRR25747755.sorted.bam

# Index bam file
samtools index --threads 6 SRR8082143.sorted.bam

# Compute genotype likelihoods (map quality > 60; quality score > 40; mapped reads > 10)
bcftools mpileup -Ou --threads 6 --min-MQ 60 -f ecoli_MG1655.fasta SRR8082143.sorted.bam | bcftools call --threads 6 -mv -Ou --ploidy 1 - | bcftools filter -Oz -e 'QUAL<40 || DP<10' > SRR8082143_Final.vcf.gz

# Generate index file
bcftools index SRR8082143_Final.vcf.gz