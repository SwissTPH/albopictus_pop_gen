#!/bin/bash
#SBATCH --job-name=alignment_albo
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=10G
#SBATCH --array=1-566
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/alignment/err_out/alignment__%a.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/alignment/err_out/alignment__%a.ERROR.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

# Load the module
ml purge
module load BWA/0.7.18-GCCcore-12.3.0
module load SAMtools/1.18-GCC-12.3.0
#module load BamTools/2.4.0-goolf-1.7.20
module load BamTools/2.5.2-GCC-12.3.0

# Directories
FASTQ_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/demultiplexed/
OUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/alignment/
GENOME=/scicore/home/muellepi/GROUP/albopictus/genome/albogenome/nuclear/Yale_genome/ae_albopictus_scaffolds.fa
SAMPLESHEET=${FASTQ_DIR}/all_samples.txt

threads=$SLURM_CPUS_PER_TASK

line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLESHEET")

name=$(echo "$line" | awk '{print $1}')
r1=$(echo "$line" | awk '{print $2}')
r2=$(echo "$line" | awk '{print $3}')

bwa mem -T 30 -t $threads ${GENOME} $r1 $r2 > ${OUT_DIR}/${name}_aligned.sam
samtools fixmate -O bam ${OUT_DIR}/${name}_aligned.sam ${OUT_DIR}/${name}_aligned.bam
samtools sort -O bam -o ${OUT_DIR}/${name}_aligned_sorted.bam ${OUT_DIR}/${name}_aligned.bam
bamtools filter \
    -tag "NM:<4" \
    -in ${OUT_DIR}/${name}_aligned_sorted.bam \
    -out ${OUT_DIR}/${name}_aligned_sorted_filtered.bam

samtools index ${OUT_DIR}/${name}_aligned_sorted_filtered.bam
