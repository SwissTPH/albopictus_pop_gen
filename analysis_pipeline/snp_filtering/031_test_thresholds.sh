#!/bin/bash
#SBATCH --job-name=031_test_thresholds
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/031_test_thresholds/err_out/031_test_thresholds.%a.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/031_test_thresholds/err_out/031_test_thresholds.%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch
#SBATCH --array=1-56%56

ml VCFtools

VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/021_inspect_metrics/populations.snps.filtered2.vcf.gz
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/utils/

SEEDFILE=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/snp_filtering//filter_parameters.csv
SEED_STR=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SEEDFILE)
IFS=',' read -r -a SEED_ARRAY <<< "$SEED_STR"

MISS="${SEED_ARRAY[0]}"
MIN_DEPTH="${SEED_ARRAY[1]}"

MAX_DEPTH=30

EXP=filter_FM_${MISS}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}

OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/031_test_thresholds/031_$EXP
mkdir -p $OUT_FOLDER



VCF_OUT=${OUT_FOLDER}/populations.snps.$EXP.vcf

vcftools --gzvcf $VCF_IN \
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

python3 ${SCRIPT_DIR}/regroup_metrics.py ${OUT_FOLDER}/metrics ${OUT_FOLDER}/

gzip $VCF_OUT

