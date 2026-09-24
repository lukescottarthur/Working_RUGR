#!/bin/bash
#SBATCH --job-name=reads_integrity_check
#SBATCH --output=download_%j.log
#SBATCH --time=2:00:00  
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=4G          
#SBATCH --partition=batch
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=END,FAIL


# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env


OUT=/home/las80898/GENE8940_parallel_2/gzip_check.txt

find /work/hblab/grouse_georgia_reads -name '*.fq.gz' -print0 | xargs -0 -P 8 -I{} sh -c 'gzip -t "{}" && echo "OK {}" || echo "CORRUPT {}"' > "$OUT"

echo "Checked $(wc -l < "$OUT") files; $(grep -c CORRUPT "$OUT" || true) corrupt"
grep CORRUPT "$OUT" || true