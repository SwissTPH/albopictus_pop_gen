#!/bin/bash
#SBATCH --job-name=020_metrics
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --time=06:00:00
#SBATCH --qos=6hours
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/020_compute_metrics/err_out/metrics.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/020_compute_metrics/err_out/metrics.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

#load modules
ml VCFtools
ml Python/3.14

#directories
BASE_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering
VCF_IN=${BASE_DIR}/010_first_pass_filter/populations.snps.filtered1.vcf.gz
SCRIPT_DIR=${BASE_DIR}/020_compute_metrics
OUT_FOLDER=${BASE_DIR}/020_compute_metrics/020_metrics

#compute matrices
python3 ${SCRIPT_DIR}/compute_allele_balance.py $VCF_IN > ${OUT_FOLDER}/allele_balance.tsv
python3 ${SCRIPT_DIR}/vcf_to_depth_matrix.py $VCF_IN > ${OUT_FOLDER}/depth_matrix.tsv
python3 ${SCRIPT_DIR}/vcf_to_genotype_matrix.py $VCF_IN > ${OUT_FOLDER}/genotype_matrix.tsv

#compute metrics with VCFtools
vcftools --gzvcf $VCF_IN --freq2 --out ${OUT_FOLDER}/allele_freq --max-alleles 2
vcftools --gzvcf $VCF_IN --site-mean-depth --out ${OUT_FOLDER}/site_depth
vcftools --gzvcf $VCF_IN --site-quality --out ${OUT_FOLDER}/site_quality
vcftools --gzvcf $VCF_IN --missing-site --out ${OUT_FOLDER}/site_missing
vcftools --gzvcf $VCF_IN --depth --out ${OUT_FOLDER}/ind_depth
vcftools --gzvcf $VCF_IN --missing-indv --out ${OUT_FOLDER}/ind_missing
vcftools --gzvcf $VCF_IN --het --out ${OUT_FOLDER}/ind_het


