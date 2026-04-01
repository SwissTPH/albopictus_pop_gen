#!/bin/bash
#SBATCH --job-name=092_PCA_no_indonesia
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/092_PCA_no_indonesia.out
#SBATCH --error=logs/092_PCA_no_indonesia.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

ml VCFtools
ml PLINK/1.90-beta-7.4-x86_64

OUT_FOLDER=$SLURM_JOB_NAME
mkdir -p $OUT_FOLDER

IN_FOLDER=091_remove_indonesian_samples

# pca 
for NAME in FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.no_indonesia FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.no_indonesia.native 
do
 plink --vcf ${IN_FOLDER}/${NAME}.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --make-bed --pca 300 --out ${OUT_FOLDER}/${NAME}
done
