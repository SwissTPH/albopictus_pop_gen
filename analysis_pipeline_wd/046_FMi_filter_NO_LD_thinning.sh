#!/bin/bash
#SBATCH --job-name=046_FMi_filter_NO_LD_thinning
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/046_FMi_filter_NO_LD_thinning.out
#SBATCH --error=logs/046_FMi_filter_NO_LD_thinning.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

ml VCFtools
ml PLINK/1.90-beta-7.4-x86_64


FM_SNP="0.70"
MIN_DEPTH="2"
MAX_DEPTH="30"

FM_IND="0.35"


IN_FOLDER=045_FMi_filter_and_LD_thinning/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}

OUT_FOLDER=046_FMi_filter_NO_LD_thinning/

mkdir -p $OUT_FOLDER


## filtering individuals based on fraction missing

VCF_IN=${IN_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}.first_step.vcf.gz

VCF_OUT=${OUT_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}


FILTER_INDV=${IN_FOLDER}/first_step.in.txt


## apply the filter ... 
plink --vcf $VCF_IN --keep $FILTER_INDV \
      --no-sex --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --recode vcf bgz --out $VCF_OUT


vcftools --gzvcf ${VCF_OUT}.vcf.gz --freq2 --max-alleles 2 --out ${OUT_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}
vcftools --gzvcf ${VCF_OUT}.vcf.gz --site-mean-depth --out ${OUT_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-site --out ${OUT_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}
vcftools --gzvcf ${VCF_OUT}.vcf.gz --depth --out ${OUT_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-indv --out ${OUT_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}


python3 regroup_metrics.py ${OUT_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND} ${OUT_FOLDER}/FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}.

