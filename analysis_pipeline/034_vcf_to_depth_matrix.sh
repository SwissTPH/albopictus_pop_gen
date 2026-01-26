#!/bin/bash
#SBATCH --job-name=034_vcf_to_depth_matrix
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/034_vcf_to_depth_matrix.out
#SBATCH --error=logs/034_vcf_to_depth_matrix.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

VCF_IN=020_repeat_region_filter/populations.snps.filter2.vcf
OUT_FOLDER=030_metrics

python3 vcf_to_depth_matrix.py $VCF_IN > ${OUT_FOLDER}/depth_matrix.tsv

