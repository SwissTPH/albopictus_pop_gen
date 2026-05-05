#!/bin/bash
#SBATCH --job-name=LD_thinning
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/047_LD_thinning_bcftools/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/047_LD_thinning_bcftools/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

# modules
module purge
module load PLINK/1.90-beta-7.6-x86_64
module load BCFtools
module load VCFtools

# directories
OUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/047_LD_thinning_bcftools
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/python
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/031_test_thresholds/031_filter_FM_0.65_mD_3_MD_30/populations.snps.filter_FM_0.65_mD_3_MD_30.vcf.gz

# STEP 1: LD based thinning
# convert vcf to bed file
plink \
    --vcf ${VCF_IN} \
    --double-id \
    --allow-extra-chr \
    --make-bed \
    --out ${OUT_DIR}/data

# LD pruning
plink \
    --bfile ${OUT_DIR}/data \
    --allow-extra-chr \
    --indep-pairwise 50 10 0.1 \
    --out ${OUT_DIR}/pruned

# create .txt file with all SNPs to keep
cut -f1 ${OUT_DIR}/pruned.prune.in > ${OUT_DIR}/snps_to_keep.txt

# extract SNPs from initial .vcf file
bcftools view \
    -i "ID=@${OUT_DIR}/snps_to_keep.txt" \
    -Ou \
    ${VCF_IN} \
| bcftools sort \
    -Oz \
    -o ${OUT_DIR}/data_pruned.vcf.gz

# index AFTER sorting
bcftools index ${OUT_DIR}/data_pruned.vcf.gz

VCF_FINAL=${OUT_DIR}/data_pruned.vcf.gz


# STEP 2: compute metrics
PREFIX=${OUT_DIR}/LD_thin

vcftools --gzvcf ${VCF_FINAL} --freq2 --max-alleles 2 --out $PREFIX
vcftools --gzvcf ${VCF_FINAL} --site-mean-depth --out $PREFIX
vcftools --gzvcf ${VCF_FINAL} --missing-site --out $PREFIX
vcftools --gzvcf ${VCF_FINAL} --depth --out $PREFIX
vcftools --gzvcf ${VCF_FINAL} --missing-indv --out $PREFIX

python3 ${SCRIPT_DIR}/regroup_metrics.py $PREFIX ${PREFIX}
