#!/bin/bash
#SBATCH --job-name=gstacks_albo
#SBATCH --partition=bigmem
#SBATCH --mem=200G
#SBATCH --cpus-per-task=4
#SBATCH --time=1-00:00:00
#SBATCH --qos=1day
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/gstacks/err_out/gstacks.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/gstacks/err_out/gstacks.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

GSTACKS=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v3/Compiler/gcccore/stacks/2.67/bin/gstacks

$GSTACKS \
-I /scicore/home/muellepi/GROUP/albopictus/alignments/AlboAlign/NewGenome/ \
-S _aligned_sorted_filtered.bam \
-M /scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/popmap_albo.txt \
-O /scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/gstacks/ \
-t 4

