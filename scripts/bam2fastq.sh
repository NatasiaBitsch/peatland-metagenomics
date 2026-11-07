#!/usr/bin/bash -l
#SBATCH --job-name=bam2fastq
#SBATCH --output=/home/student.aau.dk/hj03bu/carbivore/bam2fastq/logs/bam2fastq_%A_%a.out
#SBATCH --array=1-16%4                # all 16 BAMs (lines in bam_list.txt), max 4 at once. Override in terminal: sbatch --array=1 ...
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=1-00:00:00             # 24 h 

# Load software first (BioCloud uses mamba; the "-l" in the first line makes this work on compute nodes)
mamba activate samtools

# Stop on the first error
set -euo pipefail

# ---------- paths ----------
WORKDIR=/home/student.aau.dk/hj03bu/carbivore/bam2fastq
RAWDIR=/raw_data/CMS/202610_peatland
BAM_LIST=$WORKDIR/bam_list.txt
OUTDIR=$WORKDIR/fastq

mkdir -p "$OUTDIR"
if [[ ! -s "$BAM_LIST" ]]; then
    ls "$RAWDIR"/*.bam > "$BAM_LIST"      # made automatically the first time
fi

BAM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$BAM_LIST")
SAMPLE=$(basename "$BAM" .bam)
THREADS="$(nproc)"                        # CPUs SLURM actually gave the job

echo "[$(date)] task ${SLURM_ARRAY_TASK_ID} on $(hostname), ${THREADS} threads"
echo "samtools: $(samtools --version | head -n 1)"
echo "input:  $BAM ($(du -h "$BAM" | cut -f1))"
echo "output: $OUTDIR/${SAMPLE}.fastq.gz"

# -F 0x900 : skip secondary/supplementary alignments, so each read is written once
# -c 6     : gzip compression level (threads speed up the compression)
# Written as .partial first and renamed only when finished, so an unfinished file is obvious.
samtools fastq -@ "$THREADS" -F 0x900 -c 6 \
    -0 "$OUTDIR/${SAMPLE}.partial.fastq.gz" "$BAM"

mv "$OUTDIR/${SAMPLE}.partial.fastq.gz" "$OUTDIR/${SAMPLE}.fastq.gz"

echo "[$(date)] done: $SAMPLE"
ls -lh "$OUTDIR/${SAMPLE}.fastq.gz"