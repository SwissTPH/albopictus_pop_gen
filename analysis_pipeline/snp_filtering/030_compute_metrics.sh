#!/bin/bash
#SBATCH --job-name=030_compute_metrics
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/030_compute_metrics/err_out/metrics.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/030_compute_metrics/err_out/metrics.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

#load module
ml VCFtools

#define directories
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/021_inspect_metrics/populations.snps.filtered2.vcf.gz
OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/030_compute_metrics/

vcftools --gzvcf $VCF_IN --freq2 --max-alleles 2 --out ${OUT_FOLDER}/metrics
vcftools --gzvcf $VCF_IN --site-mean-depth --out ${OUT_FOLDER}/metrics
vcftools --gzvcf $VCF_IN --missing-site --out ${OUT_FOLDER}/metrics
vcftools --gzvcf $VCF_IN --depth --out ${OUT_FOLDER}/metrics
vcftools --gzvcf $VCF_IN --missing-indv --out ${OUT_FOLDER}/metrics

python3 regroup_metrics.py ${OUT_FOLDER}/metrics ${OUT_FOLDER}
