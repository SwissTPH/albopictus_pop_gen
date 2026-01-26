#!/bin/bash
#SBATCH --job-name=061_PCA
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/061_PCA.out
#SBATCH --error=logs/061_PCA.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

ml VCFtools
ml PLINK/1.90-beta-7.4-x86_64

OUT_FOLDER=$SLURM_JOB_NAME
mkdir -p $OUT_FOLDER

IN_FOLDER=053_removing_siblings

# pca 
for NAME in FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.native FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.invaded
do
 plink --vcf ${IN_FOLDER}/${NAME}.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --make-bed --pca 300 --out ${OUT_FOLDER}/${NAME}
done
