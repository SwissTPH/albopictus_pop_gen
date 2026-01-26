#!/bin/bash
#SBATCH --job-name=032_compute_various_metrics
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=01:30:00 
#SBATCH --qos=6hours
#SBATCH --output=logs/032_compute_various_metrics.out
#SBATCH --error=logs/032_compute_various_metrics.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

ml VCFtools

VCF_IN=020_repeat_region_filter/populations.snps.filter2.vcf
OUT_FOLDER=030_metrics

# allele frequency
vcftools --vcf $VCF_IN --freq2 --out ${OUT_FOLDER}/allele_freq --max-alleles 2
# mean depth per site
vcftools --vcf $VCF_IN --site-mean-depth --out ${OUT_FOLDER}/site_depth
# site quality
vcftools --vcf $VCF_IN --site-quality --out ${OUT_FOLDER}/site_quality
# missing data per site
vcftools --vcf $VCF_IN --missing-site --out ${OUT_FOLDER}/site_missing

# mean depth per individual
vcftools --vcf $VCF_IN --depth --out ${OUT_FOLDER}/ind_depth
# missing data per individual
vcftools --vcf $VCF_IN --missing-indv --out ${OUT_FOLDER}/ind_missing


# heterozygosity and inbreeding coefficient . 
# NB: not so appropriate because we have multiple pop
# but it could be useful to flag outlier individuals
vcftools --vcf $VCF_IN --het --out ${OUT_FOLDER}/ind_het

