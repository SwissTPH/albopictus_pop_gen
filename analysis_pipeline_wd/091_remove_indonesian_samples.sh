#!/bin/bash
#SBATCH --job-name=091_remove_indonesian_samples
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/091_remove_indonesian_samples.out
#SBATCH --error=logs/091_remove_indonesian_samples.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

ml Python/3.10.8-GCCcore-12.2.0


OUT_FOLDER=$SLURM_JOB_NAME
mkdir -p $OUT_FOLDER

# all
IN_FOLDER=053_removing_siblings
VCF_IN=${IN_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.vcf.gz
VCF_OUT=${OUT_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.no_indonesia

python remove_individuals_from_vcf.py ${VCF_IN} \
                                      indonesia_sample.txt \
                                      ${VCF_OUT}.vcf.gz


VCF_IN=${VCF_OUT}.vcf.gz

## native ( = remove invaded )
FILTER_INDV=invaded_filtered_individuals.txt
VCF_OUT=${OUT_FOLDER}/FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.no_indonesia.native
python remove_individuals_from_vcf.py ${VCF_IN} \
                                      $FILTER_INDV \
                                      ${VCF_OUT}.vcf.gz

## no need to do invaded only : indonesia is native
