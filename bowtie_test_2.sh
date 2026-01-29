#!/bin/bash
#SBATCH --job-name=testBowtie2                      # Job name (testBowtie2)
#SBATCH --partition=batch           # Partition name (batch, highmem, or gpu)
#SBATCH --ntasks=1                                  # 1 task (process)
#SBATCH --cpus-per-task=4                           # CPU core count per task
#SBATCH --mem=8G                                    # Memory per node (8GB)
#SBATCH --time=1:00:00                              # Time limit hrs:mins:secs
#SBATCH --output=/home/las80898/GENE8940_parallel/%x_%j.out  # Output log
#SBATCH --mail-user=las80898@uga.edu                # Where to send mail (to me)
#SBATCH --mail-type=END,FAIL                        # Mail events

# make output directory
mkdir -p /home/las80898/GENE8940_parallel/bowtie_test

# change directory into output directory
cd /home/las80898/GENE8940_parallel/bowtie_test

# copy test files to output directory
cp -rp /usr/local/training/Teach/* .

# Load bowtie2 software module
ml Bowtie2/2.5.4-GCC-13.3.0  

# run bowtie2 using 4 threads
bowtie2 --threads 4 -x index/lambda_virus -U myreads.fq
