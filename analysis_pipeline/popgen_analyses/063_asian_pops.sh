#!/bin/bash
#SBATCH --job-name=063_asian_pops
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/asian_populations/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/asian_populations/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

# load modules
module load PLINK/1.90-beta-7.6-x86_64

VCF=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/FM_0.65_mD_3_MD_30_FMi_0.3/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin.vcf.gz
OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/asian_populations
POPMAP=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popmap_albo.txt

#create keep file with populations to include in PCA
awk '$2=="Indonesia" || $2=="Hongkong" || $2=="Malaysia" || $2=="Philippines" || $2=="Singapore" || $2=="Vietnam" || $2=="Mauritius" || $2=="SriLanka" || $2=="Guangzhou" || $2=="Taiwan" || $2=="Vanuatu" || $2=="Thailand" {print $1, $1}' \
$POPMAP > ${OUT_FOLDER}/asian_pops.keep

# PCA
# prepare PLINK files once
plink --vcf ${VCF} \
      --double-id \
      --allow-extra-chr \
      --set-missing-var-ids @:# \
      --make-bed \
      --out ${OUT_FOLDER}/LD_thin_asian_pops

# PCA
plink --bfile ${OUT_FOLDER}/LD_thin_asian_pops \
      --double-id \
      --allow-extra-chr \
      --keep ${OUT_FOLDER}/asian_pops.keep \
      --pca 300 \
      --out ${OUT_FOLDER}/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_asian_pops


