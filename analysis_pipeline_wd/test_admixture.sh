#!/bin/bash
#SBATCH --job-name=test_admixture
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --time=06:00:00 
#SBATCH --qos=6hours
#SBATCH --output=logs/test_admixture.out
#SBATCH --error=logs/test_admixture.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi

NUM_THREAD=16


NUM_BS=100


OUTPUT_DIR=$SLURM_JOB_NAME
mkdir -p $OUTPUT_DIR

INFOLDER=061_PCA
INNAME=FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed

## cp data while switching chromosome names to integers
sed 's/^scaffold_//g' ${INFOLDER}/${INNAME}.bim > ${OUTPUT_DIR}/${INNAME}.bim
cp ${INFOLDER}/${INNAME}.bed  ${OUTPUT_DIR}/${INNAME}.bed
cp ${INFOLDER}/${INNAME}.fam  ${OUTPUT_DIR}/${INNAME}.fam


ml ADMIXTURE

## move to the output folder  
cd ${OUTPUT_DIR}
for K in {3..5}
do
 admixture -j${NUM_THREAD} --seed=210889 --cv -B${NUM_BS} ${INNAME}.bed $K > test_admixture.$K.output
done
