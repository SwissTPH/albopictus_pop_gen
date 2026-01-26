#!/bin/bash
#SBATCH --job-name=035_vcf_to_genotype_matrix
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=01:30:00 
#SBATCH --qos=6hours
#SBATCH --output=logs/035_vcf_to_genotype_matrix.out
#SBATCH --error=logs/035_vcf_to_genotype_matrix.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

VCF_IN=020_repeat_region_filter/populations.snps.filter2.vcf
OUT_FOLDER=030_metrics

python3 vcf_to_genotype_matrix.py $VCF_IN > ${OUT_FOLDER}/genoype_matrix.tsv


