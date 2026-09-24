#!/bin/bash
#SBATCH --job-name=reads_download_wgs_dropbox
#SBATCH --output=download_%j.log
#SBATCH --time=24:00:00   # Generous time limit for large WGS files
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G          # Low memory footprint needed for downloading
#SBATCH --partition=batch
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=END,FAIL



# Move to the directory where you want the fastq files saved
cd /work/hblab/grouse_georgia_reads

# --trust-server-names uses the actual fastq.gz filename instead of '?dl=1'
# --content-disposition handles Dropbox's header naming redirections
wget -c -i reads_download_list.txt
