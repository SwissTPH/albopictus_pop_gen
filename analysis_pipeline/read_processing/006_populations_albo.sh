#!/bin/bash
#SBATCH --job-name=populations_albo
#SBATCH --partition=bigmem
#SBATCH --mem=200G
#SBATCH --cpus-per-task=4
#SBATCH --time=1-00:00:00
#SBATCH --qos=1day
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/populations/err_out/populations.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/populations/err_out/populations.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

POPULATIONS=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v3/Compiler/gcccore/stacks/2.67/bin/populations

#define directories
INPUT=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/gstacks
OUTPUT=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/populations
POPMAP=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/popmap_albo.txt

$POPULATIONS \
-P $INPUT \
-O $OUTPUT \
--popmap $POPMAP \
-p 1 \
-r 0.25 \
--plink \
--vcf \
--threads 4
