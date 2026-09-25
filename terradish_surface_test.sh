#!/bin/bash
#SBATCH --job-name=terradish_recommended_settings                     # Job name
#SBATCH --partition=batch		                                # Partition (queue) name
#SBATCH --ntasks=1			                                    # Single task job
#SBATCH --cpus-per-task=16	                                # Number of cores per task - match this to the num_threads used by BLAST
#SBATCH --mem=256gb			                                    # Total memory for job
#SBATCH --time=24:00:00  		                                # Time limit hrs:min:sec
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error    # Standard error log
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out	# Standard output log
#SBATCH --mail-user=las80898@uga.edu                            # Where to send mail (replace cbergman with your myid)
#SBATCH --mail-type=END,FAIL                                    # Mail events (BEGIN, END, FAIL, ALL)

# testing terradish
# activate R conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate r_env_terradish

# run R script
R --no-save < /home/las80898/GENE8940_parallel_2/terradish_mem_ram_check.R