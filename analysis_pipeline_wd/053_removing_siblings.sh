#!/bin/bash
#SBATCH --job-name=053_removing_siblings
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/053_removing_siblings.out
#SBATCH --error=logs/053_removing_siblings.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

ml Python/3.10.8-GCCcore-12.2.0


OUT_FOLDER=$SLURM_JOB_NAME
mkdir -p $OUT_FOLDER

# LDthin

IN_FOLDER=045_FMi_filter_and_LD_thinning/FM_0.70_mD_2_MD_30_FMi_0.35
VCF_IN=${IN_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.vcf.gz
VCF_OUT=${OUT_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed

python remove_individuals_from_vcf.py ${VCF_IN} \
                                      relatedness_analysis.indv_to_remove.txt \
                                      ${VCF_OUT}.vcf.gz


VCF_IN=${VCF_OUT}.vcf.gz

## native ( = remove invaded )
FILTER_INDV=invaded_filtered_individuals.txt
VCF_OUT=${OUT_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.native
python remove_individuals_from_vcf.py ${VCF_IN} \
                                      $FILTER_INDV \
                                      ${VCF_OUT}.vcf.gz

## invaded ( = remove native )
FILTER_INDV=native_filtered_individuals.txt
VCF_OUT=${OUT_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.invaded
python remove_individuals_from_vcf.py ${VCF_IN} \
                                      $FILTER_INDV \
                                      ${VCF_OUT}.vcf.gz



## no-LDthin

IN_FOLDER=046_FMi_filter_NO_LD_thinning
VCF_IN=${IN_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35.vcf.gz
VCF_OUT=${OUT_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35.siblings_removed
python remove_individuals_from_vcf.py ${VCF_IN} \
                                      relatedness_analysis.indv_to_remove.txt \
                                      ${VCF_OUT}.vcf.gz


VCF_IN=${VCF_OUT}.vcf.gz

## native ( = remove invaded )
FILTER_INDV=invaded_filtered_individuals.txt
VCF_OUT=${OUT_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35.siblings_removed.native
python remove_individuals_from_vcf.py ${VCF_IN} \
                                      $FILTER_INDV \
                                      ${VCF_OUT}.vcf.gz

## invaded ( = remove native )
FILTER_INDV=native_filtered_individuals.txt
VCF_OUT=${OUT_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35.siblings_removed.invaded
python remove_individuals_from_vcf.py ${VCF_IN} \
                                      $FILTER_INDV \
                                      ${VCF_OUT}.vcf.gz


