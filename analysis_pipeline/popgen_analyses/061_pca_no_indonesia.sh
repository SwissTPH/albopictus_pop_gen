#!/bin/bash
#SBATCH --job-name=061_no_indonesia
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/no_indonesia/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/no_indonesia/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

# load modules
module load PLINK/1.90-beta-7.6-x86_64

VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/FM_0.65_mD_3_MD_30_FMi_0.3/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin.vcf.gz
OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/no_indonesia
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/utils
VCF_OUT=${OUT_FOLDER}/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_no_indonesia


python3 ${SCRIPT_DIR}/remove_individuals_from_vcf.py \
	${VCF_IN} \
	${OUT_FOLDER}/indonesia_sample.txt \
	${VCF_OUT}.vcf.gz

# PCA
# prepare PLINK files once
plink --vcf ${VCF_OUT}.vcf.gz \
      --double-id \
      --allow-extra-chr \
      --set-missing-var-ids @:# \
      --make-bed \
      --out ${OUT_FOLDER}/LD_thin_no_indonesia

# PCA
plink --bfile ${OUT_FOLDER}/LD_thin_no_indonesia \
      --double-id \
      --allow-extra-chr \
      --pca 300 \
      --out ${OUT_FOLDER}/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_no_indonesia

