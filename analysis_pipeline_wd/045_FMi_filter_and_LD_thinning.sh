#!/bin/bash
#SBATCH --job-name=045_FMi_filter_and_LD_thinning
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/045_FMi_filter_and_LD_thinning.%a.out
#SBATCH --error=logs/045_FMi_filter_and_LD_thinning.%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi
#SBATCH --array=1-10%10


ml VCFtools
ml PLINK/1.90b_170113


SEEDFILE=filters_045.txt
SEED_STR=$(sed -n ${SLURM_ARRAY_TASK_ID}p $SEEDFILE)
IFS=' ' read -r -a SEED_ARRAY <<< "$SEED_STR"

FM_SNP="${SEED_ARRAY[0]}"
MIN_DEPTH="${SEED_ARRAY[1]}"
MAX_DEPTH=30

FM_IND="${SEED_ARRAY[2]}"

EXP1=FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}
EXP2=FM_${FM_SNP}_mD_${MIN_DEPTH}_MD_${MAX_DEPTH}_FMi_${FM_IND}


OUT_FOLDER=045_FMi_filter_and_LD_thinning/$EXP2

mkdir -p $OUT_FOLDER


## apply threshold on FM_SNP, MIN_DEPTH, MAX_DEPTH

VCF_IN=036_apply_combined_filter/populations.snps.filter3.vcf

VCF_OUT1=$OUT_FOLDER/${EXP1}.first_step.vcf

vcftools --vcf $VCF_IN \
         --max-missing $FM_SNP \
         --min-meanDP $MIN_DEPTH \
         --minDP $MIN_DEPTH \
         --maxDP $MAX_DEPTH \
         --recode --stdout > $VCF_OUT1

vcftools --vcf $VCF_OUT1 --freq2 --max-alleles 2 --out ${OUT_FOLDER}/metrics.first_step
vcftools --vcf $VCF_OUT1 --site-mean-depth --out ${OUT_FOLDER}/metrics.first_step
vcftools --vcf $VCF_OUT1 --missing-site --out ${OUT_FOLDER}/metrics.first_step
vcftools --vcf $VCF_OUT1 --depth --out ${OUT_FOLDER}/metrics.first_step
vcftools --vcf $VCF_OUT1 --missing-indv --out ${OUT_FOLDER}/metrics.first_step

python3 regroup_metrics.py ${OUT_FOLDER}/metrics.first_step ${OUT_FOLDER}/first_step.

gzip $VCF_OUT1

## get list of individual satisfying the fraction missing per individual

python3 get_individual_lists_with_fraction_missing_threshold.py ${OUT_FOLDER}/first_step.indv_metrics.csv \
                  $FM_IND \
                  ${OUT_FOLDER}/first_step



## LD-based thinning and 
## filtering individuals based on fraction missing

VCF_IN=$VCF_OUT1.gz
VCF_OUT=${OUT_FOLDER}/${EXP2}_LD_thin


FILTER_INDV=${OUT_FOLDER}/first_step.in.txt
FILTER_NATIVE=${OUT_FOLDER}/first_step.in.native.txt
awk '{print $1"_"$1" "$1"_"$1}'  $FILTER_NATIVE > $OUT_FOLDER/tmp.filter_native #plink name weirdness

FILTER_INVADED=${OUT_FOLDER}/first_step.in.invaded.txt
awk '{print $1"_"$1" "$1"_"$1}'  $FILTER_INVADED > $OUT_FOLDER/tmp.filter_invaded #plink name weirdness



plink --vcf $VCF_IN --keep $FILTER_INDV --indep-pairwise 50 10 0.1 \
      --no-sex --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --out ${OUT_FOLDER}/LD_thin

## now apply the filter ... 
plink --vcf $VCF_IN --keep $FILTER_INDV \
      --no-sex --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --extract ${OUT_FOLDER}/LD_thin.prune.in \
      --recode vcf bgz --out $VCF_OUT


vcftools --gzvcf ${VCF_OUT}.vcf.gz --freq2 --max-alleles 2 --out ${OUT_FOLDER}/LD_thin
vcftools --gzvcf ${VCF_OUT}.vcf.gz --site-mean-depth --out ${OUT_FOLDER}/LD_thin
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-site --out ${OUT_FOLDER}/LD_thin
vcftools --gzvcf ${VCF_OUT}.vcf.gz --depth --out ${OUT_FOLDER}/LD_thin
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-indv --out ${OUT_FOLDER}/LD_thin

# pca 
plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --make-bed --pca 300 --out ${OUT_FOLDER}/LD_thin

plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --keep $OUT_FOLDER/tmp.filter_native \
      --make-bed --pca 300 --out ${OUT_FOLDER}/LD_thin.native

plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --keep $OUT_FOLDER/tmp.filter_invaded \
      --make-bed --pca 300 --out ${OUT_FOLDER}/LD_thin.invaded


python3 regroup_metrics.py ${OUT_FOLDER}/LD_thin ${OUT_FOLDER}/LD_thin.



