#!/bin/bash
#SBATCH --job-name=031_compute_allele_balance
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=01:30:00 
#SBATCH --qos=6hours
#SBATCH --output=logs/031_compute_allele_balance.out
#SBATCH --error=logs/031_compute_allele_balance.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi


VCF_IN=020_repeat_region_filter/populations.snps.filter2.vcf

python3 compute_allele_balance.py $VCF_IN > 030_metrics/allele_balance.tsv


