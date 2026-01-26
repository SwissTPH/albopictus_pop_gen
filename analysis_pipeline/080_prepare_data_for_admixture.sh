#!/bin/bash
#SBATCH --job-name=080_prepare_data_for_admixture
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00 
#SBATCH --qos=6hours
#SBATCH --output=logs/080_prepare_data_for_admixture.out
#SBATCH --error=logs/080_prepare_data_for_admixture.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

INFOLDER=061_PCA

OUTPUT_DIR=081_admixture_all
INNAME=FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed

mkdir -p $OUTPUT_DIR
sed 's/^scaffold_//g' ${INFOLDER}/${INNAME}.bim > ${OUTPUT_DIR}/${INNAME}.bim
cp ${INFOLDER}/${INNAME}.bed ${OUTPUT_DIR}/${INNAME}.bed
cp ${INFOLDER}/${INNAME}.fam ${OUTPUT_DIR}/${INNAME}.fam


OUTPUT_DIR=082_admixture_native
INNAME=FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.native

mkdir -p $OUTPUT_DIR
sed 's/^scaffold_//g' ${INFOLDER}/${INNAME}.bim > ${OUTPUT_DIR}/${INNAME}.bim
cp ${INFOLDER}/${INNAME}.bed ${OUTPUT_DIR}/${INNAME}.bed
cp ${INFOLDER}/${INNAME}.fam ${OUTPUT_DIR}/${INNAME}.fam


OUTPUT_DIR=083_admixture_invaded
INNAME=FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.invaded

mkdir -p $OUTPUT_DIR
sed 's/^scaffold_//g' ${INFOLDER}/${INNAME}.bim > ${OUTPUT_DIR}/${INNAME}.bim
cp ${INFOLDER}/${INNAME}.bed ${OUTPUT_DIR}/${INNAME}.bed
cp ${INFOLDER}/${INNAME}.fam ${OUTPUT_DIR}/${INNAME}.fam

