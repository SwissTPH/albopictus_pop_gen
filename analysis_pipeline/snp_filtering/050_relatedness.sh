#!/bin/bash
#SBATCH --job-name=050_relatedness_computation
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/relatedness_analysis/050_relatedness_computation/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/relatedness_analysis/050_relatedness_computation/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

#load modules
module load PLINK/1.90-beta-7.6-x86_64
module load VCFtools

#directories
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/FM_0.65_mD_3_MD_30_FMi_0.3/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin.vcf.gz
OUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/relatedness_analysis/050_relatedness_computation/
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/utils

#rename sample IDs for PLINK compatibility
python3 ${SCRIPT_DIR}/rename_vcf_gzip_samples_for_plink.py ${VCF_IN} ${OUT_DIR}/LD_thin.renamed.vcf.gz

#relatedness with vcftools
vcftools \
    --gzvcf ${OUT_DIR}/LD_thin.renamed.vcf.gz \
    --relatedness2 \
    --out ${OUT_DIR}/LD_thin


#create genomic relationship matrix with PLINK
plink \
    --vcf ${OUT_DIR}/LD_thin.renamed.vcf.gz \
    --id-delim @ \
    --allow-extra-chr \
    --make-grm-gz no-gz \
    --out ${OUT_DIR}/LD_thin
