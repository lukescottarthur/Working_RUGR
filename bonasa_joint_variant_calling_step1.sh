#!/bin/bash
#SBATCH --job-name=joint_variant_calling_step1
#SBATCH --partition=batch
#SBATCH --ntasks=1                          # Each array task runs as 1 process
#SBATCH --cpus-per-task=4                   # 4 CPUs per sample (see notes)
#SBATCH --mem=16G                           # Memory per array task
#SBATCH --time=4:00:00                     # Per-task time limit
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

# set reference
REF=/scratch/las80898/bonasa/Bumbellus.assembly.fa

# split genome into ~N_CHUNKS interval files for parallel calling
N_CHUNKS=54   # match your old array size, or reduce if genome is small
awk -v n=$N_CHUNKS '{print $1"\t"$2}' "${REF}.fai" \
  | python3 -c "
import sys
contigs = [(l.split()[0], int(l.split()[1])) for l in sys.stdin]
total = sum(l for _,l in contigs)
n = $N_CHUNKS
target = total / n
chunks = []
cur = []
cur_len = 0
for name, length in contigs:
    cur.append(f'{name}')
    cur_len += length
    if cur_len >= target:
        chunks.append(cur)
        cur, cur_len = [], 0
if cur:
    chunks.append(cur)
for i, c in enumerate(chunks):
    with open(f'regions_{i}.txt', 'w') as f:
        f.write('\n'.join(c) + '\n')
"
mkdir -p /scratch/las80898/bonasa/regions && mv regions_*.txt /scratch/las80898/bonasa/regions
ls /scratch/las80898/bonasa/regions | wc -l   # confirm chunk count -> set --array accordingly
