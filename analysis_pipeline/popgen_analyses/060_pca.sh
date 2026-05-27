#!/bin/bash
#SBATCH --job-name=060_pca_all_samples
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/all_samples/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/all_samples/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

# load modules
module load PLINK/1.90-beta-7.6-x86_64

VCF=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/FM_0.65_mD_3_MD_30_FMi_0.3/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin.vcf.gz
OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/all_samples

# PCA
# prepare PLINK files once
plink --vcf ${VCF} \
      --double-id \
      --allow-extra-chr \
      --set-missing-var-ids @:# \
      --make-bed \
      --out ${OUT_FOLDER}/LD_thin

# PCA all
plink --bfile ${OUT_FOLDER}/LD_thin \
      --double-id \
      --allow-extra-chr \
      --pca 300 \
      --out ${OUT_FOLDER}/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_all_samples

