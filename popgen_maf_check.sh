#!/bin/bash
#SBATCH --job-name=popgen_maf_check
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=128G
#SBATCH --time=8:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

OUTDIR="/scratch/las80898/bonasa/popgen/cohort_files"

cd $OUTDIR

echo "=== Check: sort order (contig-aware) ==="
# For each contig, confirm positions are monotonically non-decreasing,
# and confirm no contig's records are split into more than one block.
zcat cohort_filtered_allsites.vcf.gz | grep -v "^#" | awk '
{
    if ($1 != prev_chr) {
        if (($1 in seen)) {
            print "ERROR: contig " $1 " appears in more than one block (not properly grouped)" > "/dev/stderr"
            exit 1
        }
        seen[$1] = 1
        prev_pos = 0
    }
    if ($2 < prev_pos) {
        print "ERROR: position out of order within contig " $1 ": " prev_pos " -> " $2 > "/dev/stderr"
        exit 1
    }
    prev_pos = $2
    prev_chr = $1
}
END { print "Sort check passed: positions ascend within each contig; no contig appears in multiple blocks." }
'

echo "=== Check: tabix re-validation ==="
if tabix -f -p vcf cohort_filtered_allsites.vcf.gz; then
    echo "tabix confirms file is properly sorted and indexed."
else
    echo "ERROR: tabix indexing failed — file is not properly sorted." >&2
    exit 1
fi
