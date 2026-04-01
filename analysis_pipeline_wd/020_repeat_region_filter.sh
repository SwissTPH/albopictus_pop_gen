#!/bin/bash
#SBATCH --job-name=020_repeat_region_filter
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/020_repeat_region_filter.out
#SBATCH --error=logs/020_repeat_region_filter.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

mkdir -p 020_repeat_region_filter

ml VCFtools


REPEAT_BED=/scicore/home/muellepi/GROUP/albopictus/albo_repeats/ae_albopictus_scaffolds.fa.bed
VCF_IN=010_first_pass_filter/populations.snps.filter1.vcf.gz
VCF_OUT=020_repeat_region_filter/populations.snps.filter2.vcf

vcftools --gzvcf $VCF_IN \
         --exclude-bed $REPEAT_BED \
         --recode --stdout > $VCF_OUT

gzip $VCF_OUT


