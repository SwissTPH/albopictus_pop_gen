#!/bin/bash
#SBATCH --job-name=065_europe_noIMS3
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/europe_noIMS3/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/europe_noIMS3//err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

# load modules
module load PLINK/1.90-beta-7.6-x86_64

VCF=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/FM_0.65_mD_3_MD_30_FMi_0.3/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin.vcf.gz
OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/PCA/europe_noIMS3
POPMAP=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popmap_albo.txt

#create keep file with populations to include in PCA
awk '$1!="IMS3" && ($2=="Albania" || $2=="Bulgaria" || $2=="Croatia" || $2=="France" || $2=="Germany" || $2=="Greece" || $2=="Italy" || $2=="Liechtenstein" || $2=="Malta" || $2=="Montenegro" || $2=="Serbia" || $2=="Slovenia" || $2=="TurkeyWest" || $2=="TurkeyEast" || $2=="Switzerland" || $2=="Spain") {print $1, $1}' \
$POPMAP > ${OUT_FOLDER}/pops_europe.keep

# PCA
# prepare PLINK files once
plink --vcf ${VCF} \
      --double-id \
      --allow-extra-chr \
      --set-missing-var-ids @:# \
      --make-bed \
      --out ${OUT_FOLDER}/LD_thin_pops_europe_noIMS3

# PCA
plink --bfile ${OUT_FOLDER}/LD_thin_pops_europe_noIMS3 \
      --double-id \
      --allow-extra-chr \
      --keep ${OUT_FOLDER}/pops_europe.keep \
      --pca 300 \
      --out ${OUT_FOLDER}/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin_pops_europe_noIMS3


