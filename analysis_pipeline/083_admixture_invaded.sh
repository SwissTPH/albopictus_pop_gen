#!/bin/bash
#SBATCH --job-name=083_admixture_invaded
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --time=02:00:00 
#SBATCH --qos=6hours
#SBATCH --output=logs/083_admixture_invaded.%a.out
#SBATCH --error=logs/083_admixture_invaded.%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi
#SBATCH --array=2-12%10


NUM_THREAD=16

K=$SLURM_ARRAY_TASK_ID

NUM_BS=1000

OUTPUT_DIR=$SLURM_JOB_NAME
mkdir -p $OUTPUT_DIR


INNAME=FM_0.70_mD_2_MD_30_FMi_0.35_LD_thin.siblings_removed.invaded


ml ADMIXTURE
cd $OUTPUT_DIR
admixture -j${NUM_THREAD} --cv --seed=210889 -B${NUM_BS} ${INNAME}.bed $K > ${INNAME}.${K}.output
