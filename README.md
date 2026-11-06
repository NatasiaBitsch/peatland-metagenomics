# Methane cyclers in restored peatlands

MSc thesis project, Aalborg University (2026–2027)
Author: Natasia (nl21@student.aau.dk) · Supervisor: <name>

## Aim

To identify the bacterial and archaeal species central to carbon cycling in peatland
restoration sites and link them to restoration success, using bioinformatic tools to improve
recovery of high-quality genomes, with a focus on the missing methanogens.

## Approach

1. Profile peatland communities from the Microflora Danica (MFD) and MFD-X datasets with
   SingleM and Sylph (GTDB r232) to find which taxa lack genomes.
2. Apply the same pipeline to 16 new Nanopore-sequenced peatland samples, recover MAGs with
   mmlong2, and measure how much of the community they capture (`singlem appraise`).
3. Identify methanogens, ANME and methanotrophs via marker genes (mcrA, pmoA, mmoX) using
   HMMs and GraftM, and relate them to restoration status.

## Repository structure

```
scripts/
├── bam2fastq.sh       Convert Nanopore BAMs to FASTQ (SLURM array)
├── qc_reads.sh        Read statistics and filtering
└── mmlong.sh          MAG recovery with mmlong2
bam2fastq/
└── bam_list.txt       Input BAM files, one per line (array index = line number)
```

Data and outputs are kept on AAU BioCloud and are not part of this repository
(see `.gitignore`):

| Location | Contents |
|---|---|
| `/raw_data/CMS/202610_peatland/` | Raw Nanopore BAMs (read-only) |
| `bam2fastq/fastq/`, `bam2fastq/logs/` | Converted reads and SLURM logs |
| `qc/` | Read statistics, filtered reads, logs |
| `mmlong2/` | mmlong2 output (assemblies, MAGs, annotations) |
| `coverage/` | Coverage estimates |

## Data

- 16 peatland samples, Oxford Nanopore, 100–250 GB per BAM
- Basecalled with Dorado 1.4.0 (model v5.2.0 sup, simplex) including 4mC/5mC/6mA
  modified bases; methylation is kept in the original BAMs for later bin refinement
- Reference taxonomy: GTDB r232 (matching the MFD MAGs)

## Pipeline status

| Step | Script | Status |
|---|---|---|
| BAM → FASTQ | `scripts/bam2fastq.sh` | In progress |
| Read QC and filtering | `scripts/qc_reads.sh` | In progress |
| MAG recovery | `scripts/mmlong.sh` | Planned |
| Community profiling (SingleM, Sylph) | – | Planned |
| Methane marker genes (HMM, GraftM) | – | Planned |
| Synthesis and statistics (R) | – | Planned |

## Software

| Tool | Version | Purpose |
|---|---|---|
| samtools | 1.22.1 | BAM → FASTQ |
| mmlong2 | 1.2.1 | MAG recovery |
| SingleM | – | Community profiling |
| Sylph | – | Genome-based profiling |
| GraftM | – | Marker gene placement |

Scripts are written for the SLURM scheduler on AAU BioCloud and use mamba environments.
