#!/bin/bash
#SBATCH --job-name=reads_fastqc_check
#SBATCH --output=download_%j.log
#SBATCH --time=8:00:00   
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=12G         
#SBATCH --partition=batch
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=END,FAIL


# Load conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate bonasa_env

set -euo pipefail

INDIR=/work/hblab/grouse_georgia_reads
OUTDIR="/scratch/las80898/bonasa_fastqc"

# If output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

# Change directory into output directory
cd $OUTDIR



# FastQC runs one file per thread, so -t should match the CPUs requested above
fastqc -t "$SLURM_CPUS_PER_TASK" -o "$OUTDIR" "$INDIR"/*.fq.gz
 
# Combine all the individual reports into one summary
multiqc "$OUTDIR" -o "$OUTDIR" -n multiqc_raw_reads
 
echo "Done. Open $OUTDIR/multiqc_raw_reads.html"