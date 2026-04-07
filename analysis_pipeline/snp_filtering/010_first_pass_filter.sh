#!/bin/bash
#SBATCH --job-name=010_first_pass_filter
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --qos=6hours
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/010_first_pass_filter/filter1.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/010_first_pass_filter/filter1.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

# Load module
ml VCFtools

# Input files
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_calling/populations/populations.snps.vcf
REPEAT_BED=/scicore/home/muellepi/GROUP/albopictus/albo_repeats/ae_albopictus_scaffolds.fa.bed

# Output file
VCF_OUT=populations.snps.filtered1.vcf

# apply filters
vcftools --vcf $VCF_IN \
         --remove-indels \
         --max-missing 0.5 \
         --exclude-bed $REPEAT_BED \
         --recode --stdout > $VCF_OUT

# Compress final VCF
gzip $VCF_OUT
