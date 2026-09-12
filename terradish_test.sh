#!/bin/bash
#SBATCH --job-name=terradish-test		                        # Job name
#SBATCH --partition=batch		                                # Partition (queue) name
#SBATCH --ntasks=1			                                    # Single task job
#SBATCH --cpus-per-task=8		                                # Number of cores per task - match this to the num_threads used by BLAST
#SBATCH --mem=256gb			                                    # Total memory for job
#SBATCH --time=12:00:00  		                                # Time limit hrs:min:sec
#SBATCH --error=/home/las80898/GENE8940_parallel_2.%j.err     # Standard error log
#SBATCH --output=/home/las80898/GENE8940_parallel_2.%j.out	# Standard output log
#SBATCH --mail-user=las80898@uga.edu                            # Where to send mail (replace cbergman with your myid)
#SBATCH --mail-type=END,FAIL                                    # Mail events (BEGIN, END, FAIL, ALL)


# activate R conda environment
CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate r_env_terradish

# run R script
R --no-save < /home/las80898/GENE8940_parallel_2/terradish_cluster_test.R