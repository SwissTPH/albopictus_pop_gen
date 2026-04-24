#!/bin/bash
#SBATCH --job-name=040_FMi_filter_and_LD_thinning
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/err_out/output.%a.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/err_out/error.%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch
#SBATCH --array=1-10%10

set -euo pipefail

#load modules
ml purge
ml VCFtools
ml PLINK/1.90-beta-7.6-x86_64

#directories
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/021_inspect_metrics/populations.snps.filtered2.vcf.gz
OUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/
SEEDFILE=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/snp_filtering/040_filters.txt
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/python

#extract filter thresholds from file
SEED_STR=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SEEDFILE)
IFS=' ' read -r FM_SNP MIN_DEPTH FM_IND <<< "$SEED_STR"
MAX_DEPTH=30

#create system for names
EXP1=FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}
EXP2=${EXP1}_FMi_${FM_IND}

#create a new folder for each filter combination
OUT_FOLDER=${OUT_DIR}/${EXP2}
mkdir -p $OUT_FOLDER

#---------------------------------------
#STEP 1: SNP filtering
VCF_OUT1=${OUT_FOLDER}/${EXP1}.first_step.vcf

vcftools --gzvcf $VCF_IN \
  --max-missing $FM_SNP \
  --min-meanDP $MIN_DEPTH \
  --minDP $MIN_DEPTH \
  --maxDP $MAX_DEPTH \
  --recode --stdout > $VCF_OUT1

#compute metrics
PREFIX=${OUT_FOLDER}/metrics.first_step
vcftools --vcf $VCF_OUT1 --freq2 --max-alleles 2 --out $PREFIX
vcftools --vcf $VCF_OUT1 --site-mean-depth --out $PREFIX
vcftools --vcf $VCF_OUT1 --missing-site --out $PREFIX
vcftools --vcf $VCF_OUT1 --depth --out $PREFIX
vcftools --vcf $VCF_OUT1 --missing-indv --out $PREFIX

python3 ${SCRIPT_DIR}/regroup_metrics.py $PREFIX ${OUT_FOLDER}/first_step.

gzip ${VCF_OUT1}

#----------------------------------------
#STEP 2: individual filtering
python3 ${SCRIPT_DIR}/get_individual_lists_with_fraction_missing_threshold.py \
  ${OUT_FOLDER}/first_step.indv_metrics.csv \
  $FM_IND \
  ${OUT_FOLDER}/first_step

#-----------------------------------------
#STEP 3: LD thinning
VCF_IN_GZ=${VCF_OUT1}.gz
VCF_OUT=${OUT_FOLDER}/${EXP2}_LD_thin

FILTER_INDV=${OUT_FOLDER}/first_step.in.txt
FILTER_NATIVE=${OUT_FOLDER}/first_step.in.native.txt
FILTER_INVADED=${OUT_FOLDER}/first_step.in.invaded.txt

#fix PLINK IDs
awk '{print $1"_"$1" "$1"_"$1}' "$FILTER_NATIVE" > "${OUT_FOLDER}/tmp.filter_native"
awk '{print $1"_"$1" "$1"_"$1}' "$FILTER_INVADED" > "${OUT_FOLDER}/tmp.filter_invaded"

#LD pruning
plink --vcf $VCF_IN_GZ \
  --keep $FILTER_INDV \
  --indep-pairwise 50 10 0.1 \
  --no-sex --double-id --allow-extra-chr --set-missing-var-ids @:# \
  --out ${OUT_FOLDER}/LD_thin

#apply pruning
plink --vcf $VCF_IN_GZ \
  --keep $FILTER_INDV \
  --extract ${OUT_FOLDER}/LD_thin.prune.in \
  --recode vcf bgz \
  --no-sex --double-id --allow-extra-chr --set-missing-var-ids @:# \
  --out $VCF_OUT

#----------------------------------------
#STEP 4: metrics after LD thinning
PREFIX=${OUT_FOLDER}/LD_thin
vcftools --gzvcf ${VCF_OUT}.vcf.gz --freq2 --max-alleles 2 --out $PREFIX
vcftools --gzvcf ${VCF_OUT}.vcf.gz --site-mean-depth --out $PREFIX
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-site --out $PREFIX
vcftools --gzvcf ${VCF_OUT}.vcf.gz --depth --out $PREFIX
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-indv --out $PREFIX

#---------------------------------------
# STEP 5: PCA

#convert VCF to BED
plink --vcf ${VCF_OUT}.vcf.gz \
  --double-id \
  --allow-extra-chr \
  --make-bed \
  --out ${OUT_FOLDER}/LD_thin_tmp

#PCA on full dataset
plink --bfile ${OUT_FOLDER}/LD_thin_tmp \
  --pca 300 \
  --out ${OUT_FOLDER}/LD_thin

#PCA native subset
plink --bfile ${OUT_FOLDER}/LD_thin_tmp \
  --keep ${OUT_FOLDER}/tmp.filter_native \
  --pca 300 \
  --out ${OUT_FOLDER}/LD_thin.native

#PCA invaded subset
plink --bfile ${OUT_FOLDER}/LD_thin_tmp \
  --keep ${OUT_FOLDER}/tmp.filter_invaded \
  --pca 300 \
  --out ${OUT_FOLDER}/LD_thin.invaded


python3 ${SCRIPT_DIR}/regroup_metrics.py ${OUT_FOLDER}/LD_thin ${OUT_FOLDER}/LD_thin.
