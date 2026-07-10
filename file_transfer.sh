#!/bin/bash
#SBATCH --job-name=file_tranfer
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A_%a.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A_%a.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

cd /home/las80898/bonasa

mv vcf_reads_2 /scratch/las80898/bonasa/
mv popgen /scratch/las80898/bonasa/
mv pcr_reads /scratch/las80898/bonasa/
mv Bumbellus.assembly.fa /scratch/las80898/bonasa/
mv Bumbellus.assembly.fa.fai /scratch/las80898/bonasa/