#!/bin/bash
#SBATCH --job-name=041_compute_metrics
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/041_compute_metrics.out
#SBATCH --error=logs/041_compute_metrics.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

ml VCFtools

VCF_IN=036_apply_combined_filter/populations.snps.filter3.vcf
OUT_FOLDER=041_compute_metrics
mkdir -p $OUT_FOLDER

vcftools --vcf $VCF_IN --freq2 --max-alleles 2 --out ${OUT_FOLDER}/metrics
vcftools --vcf $VCF_IN --site-mean-depth --out ${OUT_FOLDER}/metrics
vcftools --vcf $VCF_IN --missing-site --out ${OUT_FOLDER}/metrics
vcftools --vcf $VCF_IN --depth --out ${OUT_FOLDER}/metrics
vcftools --vcf $VCF_IN --missing-indv --out ${OUT_FOLDER}/metrics

python3 regroup_metrics.py 041_compute_metrics/metrics 041_compute_metrics/


