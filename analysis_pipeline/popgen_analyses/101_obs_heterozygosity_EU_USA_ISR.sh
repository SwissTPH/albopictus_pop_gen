#!/bin/bash
#SBATCH --job-name=100_observed_heterozygosity
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/genetic_diversity/heterozygosity/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/genetic_diversity/heterozygosity/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

# load modules
ml VCFtools

VCF="/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/112_pca_EU_USA_ISR/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_EU_no_BGR_GER.vcf.gz"
OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/genetic_diversity/heterozygosity/

vcftools --gzvcf ${VCF} --het --out ${OUT_FOLDER}/obs_heterozygosity_EU_USA_ISR
