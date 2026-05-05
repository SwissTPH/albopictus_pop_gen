#!/bin/bash
#SBATCH --job-name=LD_thinning
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/046_LD_thinning/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/046_LD_thinning/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

# modules
module purge
module load PLINK/1.90-beta-7.6-x86_64
module load VCFtools

# directories
OUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/046_LD_thinning
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/python
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/031_test_thresholds/031_filter_FM_0.65_mD_3_MD_30/populations.snps.filter_FM_0.65_mD_3_MD_30.vcf.gz
INDV=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/046_LD_thinning/keep10.txt

# STEP 1: LD based thinning
# convert vcf to bed file
plink \
    --vcf ${VCF_IN} \
    --double-id \
    --keep $INDV \
    --allow-extra-chr \
    --make-bed \
    --out ${OUT_DIR}/data

# LD pruning
plink \
    --bfile ${OUT_DIR}/data \
    --allow-extra-chr \
    --indep-pairwise 50 10 0.1 \
    --out ${OUT_DIR}/pruned

# apply LD pruning
plink \
    --bfile ${OUT_DIR}/data \
    --allow-extra-chr \
    --extract ${OUT_DIR}/pruned.prune.in \
    --make-bed \
    --out ${OUT_DIR}/data_pruned

# export vcf file
plink \
    --bfile ${OUT_DIR}/data_pruned \
    --recode vcf \
    --allow-extra-chr \
    --out ${OUT_DIR}/data_pruned

VCF_FINAL=${OUT_DIR}/data_pruned.vcf

# STEP 2: compute metrics
PREFIX=${OUT_DIR}/LD_thin

vcftools --vcf ${VCF_FINAL} --freq2 --max-alleles 2 --out $PREFIX
vcftools --vcf ${VCF_FINAL} --site-mean-depth --out $PREFIX
vcftools --vcf ${VCF_FINAL} --missing-site --out $PREFIX
vcftools --vcf ${VCF_FINAL} --depth --out $PREFIX
vcftools --vcf ${VCF_FINAL} --missing-indv --out $PREFIX

python3 ${SCRIPT_DIR}/regroup_metrics.py $PREFIX ${PREFIX}
