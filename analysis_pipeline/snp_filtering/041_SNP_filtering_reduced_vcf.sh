#!/bin/bash
#SBATCH --job-name=041_SNP_filter_reduced_vcf
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/041_filtering_reduced_vcf/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/041_filtering_reduced_vcf/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

# Load modules
module purge
module load PLINK/1.90-beta-7.6-x86_64
module load BCFtools
module load VCFtools

# directories
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/041_filtering_reduced_vcf/populations.snps.filtered2.EU.sorted.vcf.gz
OUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/041_filtering_reduced_vcf
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/041_filtering_reduced_vcf


# Define thresholds (same as global dataset)
FM_SNP=0.65      # max missing per SNP
MIN_DEPTH=3      # min depth
MAX_DEPTH=30     # max depth
FM_IND=0.30      # max missing per individual

EXP=FM_0.65_mD_3_MD_30_FMi_0.3

#----------------------------------------------------------
# STEP 1: SNP filtering

VCF_OUT1=${OUT_DIR}/${EXP}.step1.vcf

vcftools --gzvcf ${VCF_IN} \
  --max-missing ${FM_SNP} \
  --min-meanDP ${MIN_DEPTH} \
  --minDP ${MIN_DEPTH} \
  --maxDP ${MAX_DEPTH} \
  --recode --stdout > ${VCF_OUT1}

gzip ${VCF_OUT1}

VCF_OUT1_GZ=${VCF_OUT1}.gz

#----------------------------------------------------------
# STEP 2: Individual filtering

# compute missingness per individual
vcftools --gzvcf ${VCF_OUT1_GZ} \
  --missing-indv \
  --out ${OUT_DIR}/missing

python3 ${SCRIPT_DIR}/get_individual_lists_with_fraction_missing_threshold.py \
  ${OUT_DIR}/missing.imiss \
  ${FM_IND} \
  ${OUT_DIR}/subset

FILTER_INDV=${OUT_DIR}/subset.in.txt

#----------------------------------------------------------
# STEP 3: Convert to PLINK

plink \
  --vcf ${VCF_OUT1_GZ} \
  --keep ${FILTER_INDV} \
  --double-id \
  --allow-extra-chr \
  --make-bed \
  --out ${OUT_DIR}/data

#----------------------------------------------------------
# STEP 4: LD pruning

plink \
  --bfile ${OUT_DIR}/data \
  --allow-extra-chr \
  --indep-pairwise 50 10 0.1 \
  --out ${OUT_DIR}/pruned

#----------------------------------------------------------
# STEP 5: Create final LD-pruned VCF

awk '{print $1}' ${FILTER_INDV} > ${OUT_DIR}/keep_samples.txt

FINAL_VCF=${OUT_DIR}/${EXP}_LD_thin.vcf.gz

bcftools view \
  -S ${OUT_DIR}/keep_samples.txt \
  -Ou ${VCF_OUT1_GZ} \
| bcftools view \
  -i "ID=@${OUT_DIR}/pruned.prune.in" \
  -Ou \
| bcftools sort \
  -Oz -o ${FINAL_VCF}

bcftools index ${FINAL_VCF}

#----------------------------------------------------------
# STEP 6: Summary

echo "Final SNP count:"
bcftools view -H ${FINAL_VCF} | wc -l

echo "Final sample count:"
bcftools query -l ${FINAL_VCF} | wc -l

echo "Final VCF:"
echo ${FINAL_VCF}
