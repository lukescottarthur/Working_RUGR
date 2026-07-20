#!/bin/bash
#SBATCH --job-name=popgen_A_4_ROH
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=164G
#SBATCH --time=24:00:00
#SBATCH --output=/home/las80898/GENE8940_parallel_2/%x_%A.out
#SBATCH --error=/home/las80898/GENE8940_parallel_2/%x_%A.error
#SBATCH --mail-user=las80898@uga.edu
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

# Load conda environment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate popgen_env

INDIR="/scratch/las80898/bonasa/popgen/cohort_files"
OUTDIR="/scratch/las80898/bonasa/popgen/ROH"
INPUT_VCF="cohort_filtered_allsites.vcf.gz"

# Total genome length: awk '{sum+=$2}END{print sum}' Bumbellus.assembly.fa.fai

# Filtering scaffolds to large ones
# bcftools index --stats cohort_filtered_allsites.vcf.gz | awk '$3 >= 1000000 {print $1"\t0\t"$3}' > large_scaffolds.txt

# Update genome length used in ROH to only large scaffolds: 
# bcftools index --stats cohort_filtered_allsites.vcf.gz | awk '$3 >= 1000000 {sum += $3} END {print "Autosomal-proxy bp:", sum}'

GENOME_LENGTH=949996370

cd $INDIR


# PREP VCF
bcftools view -m2 -M2 -v snps \
    --regions-file large_scaffolds.txt \
    -O u "${INPUT_VCF}" \
  | bcftools +fill-tags -O z -o cohort_prepped.vcf.gz --threads 8 -- -t AF

bcftools index -t cohort_prepped.vcf.gz

# ROH
bcftools roh \
    --AF-tag AF \
    --GT-only \
    --rec-rate 1e-8 \
    --min-markers 50 \
    --min-length 1e5 \
    -O r \
    -o $OUTDIR/roh_output.txt \
    cohort_prepped.vcf.gz

cd $OUTDIR

# Extract RG (segment) records only
grep "^RG" roh_output.txt > roh_RG_only.txt
echo "  ROH segments detected: $(wc -l < roh_RG_only.txt)"



#Calculate F_ROH as: sum of ROH length (>1Mb) / total autosomal genome length

echo "[3/3] Calculating F_ROH..."

python3 - <<PYEOF
import pandas as pd
 
GENOME_LEN = ${GENOME_LENGTH}
MIN_ROH_BP = 1_000_000   # 1 Mb — captures recent inbreeding
                          # change to 100_000 (100 kb) to include ancient inbreeding
 
cols = ["Record","SampleID","Chr","Start","End","Length_bp","Markers","Quality"]
roh = pd.read_csv("roh_RG_only.txt", sep="\t", header=None, names=cols)
roh["Length_bp"] = pd.to_numeric(roh["Length_bp"])
 
# Print length distribution across all samples
print("\nROH length distribution (all segments):")
bins   = [0, 100_000, 500_000, 1_000_000, 2_000_000, 5_000_000, float("inf")]
labels = ["<100kb","100-500kb","500kb-1Mb","1-2Mb","2-5Mb",">5Mb"]
roh["bin"] = pd.cut(roh["Length_bp"], bins=bins, labels=labels)
print(roh["bin"].value_counts().reindex(labels).to_string())
 
# Filter to ROH >= 1 Mb for F_ROH
roh_long = roh[roh["Length_bp"] >= MIN_ROH_BP]
 
# Calculate F_ROH per sample
results = []
for sample in sorted(roh["SampleID"].unique()):
    segs = roh_long[roh_long["SampleID"] == sample]
    total_bp = segs["Length_bp"].sum()
    results.append({
        "SampleID":       sample,
        "N_ROH":          len(segs),
        "Total_ROH_Mb":   round(total_bp / 1e6, 3),
        "F_ROH":          round(total_bp / GENOME_LEN, 6),
        "Longest_ROH_Mb": round(segs["Length_bp"].max() / 1e6, 3) if len(segs) > 0 else 0.0,
    })
 
df = pd.DataFrame(results).sort_values("F_ROH", ascending=False)
df.to_csv("froh_results.txt", sep="\t", index=False)
 
print(f"\nF_ROH summary (ROH >= 1 Mb, genome length = {GENOME_LEN:,} bp):")
print(f"  Mean:   {df['F_ROH'].mean():.4f}")
print(f"  Median: {df['F_ROH'].median():.4f}")
print(f"  Min:    {df['F_ROH'].min():.4f}")
print(f"  Max:    {df['F_ROH'].max():.4f}")
print(f"\nResults saved to froh_results.txt")
print(df.to_string(index=False))
PYEOF
 
echo "Done."