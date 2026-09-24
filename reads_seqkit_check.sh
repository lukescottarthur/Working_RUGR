#!/bin/bash
#SBATCH --job-name=reads_seqkit_check
#SBATCH --output=download_%j.log
#SBATCH --time=8:00:00   
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G         
#SBATCH --partition=batch
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=END,FAIL

   
# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

   
   
seqkit stats -a -j 8 /work/hblab/grouse_georgia_reads/*.fq.gz > read_stats.tsv