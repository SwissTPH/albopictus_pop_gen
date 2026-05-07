#!/bin/bash
#SBATCH --job-name=multiqc_demu
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=4G
#SBATCH --time=01:00:00
#SBATCH --qos=6hours
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/fastqc/fastqc_multiqc_demu/multiqc.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

module load MultiQC

INPUT=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/fastqc/fastqc_multiqc_demu/
OUTPUT=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/fastqc/fastqc_multiqc_demu/

multiqc $INPUT -o $OUTPUT
