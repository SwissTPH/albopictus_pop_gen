#!/bin/bash
#SBATCH --job-name=010_first_pass_filter
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/010_first_pass_filter.out
#SBATCH --error=logs/010_first_pass_filter.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

mkdir -p 010_first_pass_filter

ml VCFtools

VCF_IN=/scicore/home/muellepi/GROUP/albopictus/stacks.ref/Albo_570/populations_311019/populations.snps.vcf
VCF_OUT=010_first_pass_filter/populations.snps.filter1.vcf
vcftools --vcf $VCF_IN \
         --remove-indels \
         --max-missing 0.5 \
         --recode --stdout > $VCF_OUT

gzip $VCF_OUT

