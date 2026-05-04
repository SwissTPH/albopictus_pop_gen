#!/bin/bash
#SBATCH --job-name=test_400_thinning
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/044_test_400_thinning/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/044_test_400_thinning/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

#load modules
ml VCFtools
ml PLINK/1.90-beta-7.6-x86_64

#directories
OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/044_test_400_thinning/
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/python
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/031_test_thresholds/031_filter_FM_0.65_mD_3_MD_30/populations.snps.filter_FM_0.65_mD_3_MD_30.vcf.gz

FILTER_INDV=${OUT_FOLDER}/first_step.in.txt
FILTER_NATIVE=${OUT_FOLDER}/first_step.in.native.txt
FILTER_INVADED=${OUT_FOLDER}/first_step.in.invaded.txt

#fix PLINK ID format
awk '{print $1"_"$1" "$1"_"$1}' $FILTER_NATIVE > ${OUT_FOLDER}/tmp.filter_native
awk '{print $1"_"$1" "$1"_"$1}' $FILTER_INVADED > ${OUT_FOLDER}/tmp.filter_invaded

# STEP 1: 400bp thinning
VCF_OUT=${OUT_FOLDER}/FM_0.65_mD_3_MD_30_FMi_thin400

# convert vcf to bed file
plink --vcf $VCF_IN \
      --keep $FILTER_INDV \
      --make-bed \
      --double-id \
      --allow-extra-chr \
      --out ${OUT_FOLDER}/tmp_data

# apply 400bp thinning
plink --bfile ${OUT_FOLDER}/tmp_data \
      --allow-extra-chr \
      --bp-space 400 \
      --recode vcf bgz \
      --out $VCF_OUT

# STEP 2: compute metrics
PREFIX=${OUT_FOLDER}/thin400

vcftools --gzvcf ${VCF_OUT}.vcf.gz --freq2 --max-alleles 2 --out $PREFIX
vcftools --gzvcf ${VCF_OUT}.vcf.gz --site-mean-depth --out $PREFIX
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-site --out $PREFIX
vcftools --gzvcf ${VCF_OUT}.vcf.gz --depth --out $PREFIX
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-indv --out $PREFIX

# STEP 3: PCA
# all samples
plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr \
      --make-bed --pca 300 --out ${OUT_FOLDER}/thin400

# native samples
plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr \
      --keep $OUT_FOLDER/tmp.filter_native \
      --make-bed --pca 300 --out ${OUT_FOLDER}/thin400.native

# invaded samples
plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr \
      --keep $OUT_FOLDER/tmp.filter_invaded \
      --make-bed --pca 300 --out ${OUT_FOLDER}/thin400.invaded

python3 ${SCRIPT_DIR}/regroup_metrics.py $PREFIX ${PREFIX}.
