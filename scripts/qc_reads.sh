#!/usr/bin/bash -l
#SBATCH --job-name=qc_reads
#SBATCH --output=/home/student.aau.dk/hj03bu/carbivore/qc/logs/qc_%A_%a.out
#SBATCH --array=1-16%2                   # 16 samples, 2 at a time
#SBATCH --cpus-per-task=32               # porechop + chopper use 16 each
#SBATCH --mem=400G
#SBATCH --time=3-00:00:00                # 3 days. Change if needed 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hj03bu@bio.aau.dk    

# Set variables
dir_work="/home/student.aau.dk/hj03bu/carbivore/bam2fastq"
dir_reads="${dir_work}/fastq"
dir_qc="/home/student.aau.dk/hj03bu/carbivore/qc/reads"
dir_sif="/home/bio.aau.dk/cms/software/containers"

# Pick this task's sample from bam_list.txt (line number = task number)
bam=$(basename "$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${dir_work}/bam_list.txt")" .bam)   # file name without folder and .bam
sample="${bam%%.*}"          # remove everything from the first "." (the .PBM…dorado… ending)
sample="${sample#*_}"        # remove the date prefix before the first "_"

set -euo pipefail

mkdir -p ${dir_qc}

echo "Task ${SLURM_ARRAY_TASK_ID}: ${bam} -> ${sample}"

# Trim adapters and filter reads
echo "Trimming and filtering reads..."
singularity exec \
    --bind ${dir_reads}:/data/fastq \
    ${dir_sif}/porechop_abi.sif \
    porechop_abi \
        --input /data/fastq/${bam}.fastq.gz \
        --threads 16 \
        --discard_middle \
    | singularity exec \
        ${dir_sif}/chopper.sif \
        chopper \
            --quality 10 \
            --minlength 200 \
            --threads 16 \
    | gzip > ${dir_qc}/${sample}.fastq.gz

echo "=== Finished ${sample} ==="