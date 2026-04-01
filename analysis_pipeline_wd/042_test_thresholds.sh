#!/bin/bash
#SBATCH --job-name=042_test_thresholds
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/042_test_thresholds.%a.out
#SBATCH --error=logs/042_test_thresholds.%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi
#SBATCH --array=1-56%56

ml VCFtools

VCF_IN=036_apply_combined_filter/populations.snps.filter3.vcf


SEEDFILE=filter_parameters.csv
SEED_STR=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SEEDFILE)
IFS=',' read -r -a SEED_ARRAY <<< "$SEED_STR"

MISS="${SEED_ARRAY[0]}"
MIN_DEPTH="${SEED_ARRAY[1]}"

MAX_DEPTH=30

EXP=filter_FM_${MISS}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}

OUT_FOLDER=042_$EXP
mkdir -p $OUT_FOLDER



VCF_OUT=${OUT_FOLDER}/populations.snps.$EXP.csv

vcftools --vcf $VCF_IN \
         --max-missing $MISS \
         --min-meanDP $MIN_DEPTH \
         --minDP $MIN_DEPTH \
         --maxDP $MAX_DEPTH \
         --recode --stdout > $VCF_OUT

vcftools --vcf $VCF_OUT --freq2 --max-alleles 2 --out ${OUT_FOLDER}/metrics
vcftools --vcf $VCF_OUT --site-mean-depth --out ${OUT_FOLDER}/metrics
vcftools --vcf $VCF_OUT --missing-site --out ${OUT_FOLDER}/metrics
vcftools --vcf $VCF_OUT --depth --out ${OUT_FOLDER}/metrics
vcftools --vcf $VCF_OUT --missing-indv --out ${OUT_FOLDER}/metrics

python3 regroup_metrics.py ${OUT_FOLDER}/metrics ${OUT_FOLDER}/

gzip $VCF_OUT

