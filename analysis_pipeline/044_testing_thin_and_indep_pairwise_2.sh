#!/bin/bash
#SBATCH --job-name=test_thinning
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00 
#SBATCH --qos=30min
#SBATCH --output=logs/test_thinning2.out
#SBATCH --error=logs/test_thinning2.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=wandrille.duchemin@unibas.ch
#SBATCH --account=muellepi


ml VCFtools
ml PLINK/1.90b_170113

OUT_FOLDER=tmp2
mkdir -p $OUT_FOLDER


T=0.30

EXP=FM_0.65_mD_3

VCF_IN=042_filter_${EXP}_MD_30/populations.snps.filter_${EXP}_MD_30.csv.gz

FILTER_INDV=042_filter_${EXP}_MD_30/${EXP}FMi_${T}.in.txt
FILTER_NATIVE=042_filter_${EXP}_MD_30/${EXP}FMi_${T}.in.native.txt
awk '{print $1"_"$1" "$1"_"$1}'  $FILTER_NATIVE > $OUT_FOLDER/tmp.filter_native

FILTER_INVADED=042_filter_${EXP}_MD_30/${EXP}FMi_${T}.in.invaded.txt
awk '{print $1"_"$1" "$1"_"$1}'  $FILTER_INVADED > $OUT_FOLDER/tmp.filter_invaded

## thinning and 
## filtering individuals based on fraction missing

VCF_OUT=${OUT_FOLDER}/populations.snps.filter_FM_${EXP}_MD_30.FMi_${T}_thin400

plink --vcf $VCF_IN --keep $FILTER_INDV --bp-space 400 \
      --no-sex --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --recode vcf bgz --out $VCF_OUT

vcftools --gzvcf ${VCF_OUT}.vcf.gz --freq2 --max-alleles 2 --out ${OUT_FOLDER}/thin400
vcftools --gzvcf ${VCF_OUT}.vcf.gz --site-mean-depth --out ${OUT_FOLDER}/thin400
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-site --out ${OUT_FOLDER}/thin400
vcftools --gzvcf ${VCF_OUT}.vcf.gz --depth --out ${OUT_FOLDER}/thin400
vcftools --gzvcf ${VCF_OUT}.vcf.gz --missing-indv --out ${OUT_FOLDER}/thin400

# pca 
plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --make-bed --pca 300 --out ${OUT_FOLDER}/thin400


plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --keep $OUT_FOLDER/tmp.filter_native \
      --make-bed --pca 300 --out ${OUT_FOLDER}/thin400.native

plink --vcf ${VCF_OUT}.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# \
      --keep $OUT_FOLDER/tmp.filter_invaded \
      --make-bed --pca 300 --out ${OUT_FOLDER}/thin400.invaded



python3 regroup_metrics.py ${OUT_FOLDER}/thin400 ${OUT_FOLDER}/thin400.

echo ""
echo "*** LD ***"
echo ""

## LD-based thinning and 
## filtering individuals based on fraction missing

VCF_OUT=${OUT_FOLDER}/populations.snps.filter_FM_${EXP}_MD_30.FMi_${T}_LD_thin

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

