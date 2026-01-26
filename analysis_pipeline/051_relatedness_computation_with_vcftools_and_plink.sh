#!/bin/bash
#SBATCH --job-name=051_relatedness_computation_with_vcftools_and_plink
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/051_relatedness_computation_with_vcftools_and_plink.%a.out
#SBATCH --error=logs/051_relatedness_computation_with_vcftools_and_plink.%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi
#SBATCH --array=1-4%4


ml VCFtools
ml PLINK/1.90b_170113


SEEDFILE=filters_051.txt
SEED_STR=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SEEDFILE)
IFS=' ' read -r -a SEED_ARRAY <<< "$SEED_STR"

FM_SNP="${SEED_ARRAY[0]}"
MIN_DEPTH="${SEED_ARRAY[1]}"
MAX_DEPTH=30

FM_IND="${SEED_ARRAY[2]}"

EXP=FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}


VCF_IN=045_FMi_filter_and_LD_thinning/$EXP/${EXP}_LD_thin.vcf.gz

OUT_FOLDER=${SLURM_JOB_NAME}/$EXP
mkdir -p $OUT_FOLDER

python rename_vcf_gzip_samples_for_plink.py ${VCF_IN} ${OUT_FOLDER}/${EXP}_LD_thin.renamed.vcf.gz

vcftools --gzvcf ${OUT_FOLDER}/${EXP}_LD_thin.renamed.vcf.gz \
         --relatedness2 \
         --out ${OUT_FOLDER}/$EXP



plink --vcf ${OUT_FOLDER}/${EXP}_LD_thin.renamed.vcf.gz --id-delim @  --allow-extra-chr -make-grm-gz no-gz --out ${OUT_FOLDER}/$EXP




