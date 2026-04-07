#!/bin/bash

#SBATCH --job-name=fastqc_demultiplexed
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=02:00:00
#SBATCH --qos=6hours
#SBATCH --array=1-1140%50
#SBATCH --output=fastqc_%A_%a.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch


FILELIST=/scicore/home/muellepi/GROUP/albopictus/cleaned/combined_fq_albo/fq_list.txt
OUTPUT=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/fastqc/

mkdir -p $OUTPUT

# Load FastQC module
module load FastQC

FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $FILELIST)

# Run FastQC on that file
fastqc -t 2 -o $OUTPUT $FILE
