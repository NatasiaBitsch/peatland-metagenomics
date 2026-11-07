#!/usr/bin/bash -l
#SBATCH --job-name=nanoq_stats
#SBATCH --output=/home/student.aau.dk/hj03bu/carbivore/qc/logs/nanoq_%A_%a.out
#SBATCH --array=1-16%4                   # 16 samples, 4 at a time. Override: sbatch --array=1,3,4 ...
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=06:00:00                  # 6 h

# Load nanoq
mamba activate nanoq

# Set variables
dir_work="/home/student.aau.dk/hj03bu/carbivore/bam2fastq"
dir_qc="/home/student.aau.dk/hj03bu/carbivore/qc/reads"
dir_stats="/home/student.aau.dk/hj03bu/carbivore/qc/stats"

# Pick this task's sample from bam_list.txt (line number = task number)
bam=$(basename "$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${dir_work}/bam_list.txt")" .bam)   # file name without folder and .bam
sample="${bam%%.*}"          # remove everything from the first "." (the .PBM…dorado… ending)
sample="${sample#*_}"        # remove the date prefix before the first "_"

# Load nanoq (included in the mmlong2 environment)
conda activate /projects/microflora_danica/mmlong2/conda/mmlong2_v1.2.1

set -euo pipefail

mkdir -p ${dir_stats}

echo "Task ${SLURM_ARRAY_TASK_ID}: ${sample}"

# Read statistics on the trimmed + filtered reads
echo "Running nanoq..."
nanoq \
    --input ${dir_qc}/${sample}.fastq.gz \
    --stats \
    -vv \
    > ${dir_stats}/${sample}_nanoq.txt 2>&1

cat ${dir_stats}/${sample}_nanoq.txt

echo "=== Finished ${sample} ==="