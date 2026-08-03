#!/bin/bash
#SBATCH --job-name=088_prep_admx_all_noLIE_BGR
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/Admixture/088_089_all_pops_no_LIE_BGR/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/Admixture/088_089_all_pops_no_LIE_BGR/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

# load module
module load PLINK/1.90-beta-7.6-x86_64

# set directories
VCF=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/040_FMi_and_LD_filter/FM_0.65_mD_3_MD_30_FMi_0.3/FM_0.65_mD_3_MD_30_FMi_0.3_LD_thin.vcf.gz
POPMAP=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popmap_albo.txt
OUT_FOLDER=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/Admixture/088_089_all_pops_no_LIE_BGR

# Create keep file
awk '$2!="Liechtenstein" && $2!="Bulgaria" {print $1, $1}' \
${POPMAP} > ${OUT_FOLDER}/keep_all_no_LIE_BGR.keep


# Create PLINK files

plink \
    --vcf ${VCF} \
    --keep ${OUT_FOLDER}/keep_all_no_LIE_BGR.keep \
    --double-id \
    --allow-extra-chr \
    --set-missing-var-ids @:# \
    --make-bed \
    --out ${OUT_FOLDER}/LD_thin_all_pops_no_LIE_BGR

# Rename scaffolds for ADMIXTURE

INNAME=LD_thin_all_pops_no_LIE_BGR

sed 's/^scaffold_//g' ${OUT_FOLDER}/${INNAME}.bim \
> ${OUT_FOLDER}/${INNAME}_num.bim

cp ${OUT_FOLDER}/${INNAME}.bed ${OUT_FOLDER}/${INNAME}_num.bed
cp ${OUT_FOLDER}/${INNAME}.fam ${OUT_FOLDER}/${INNAME}_num.fam
