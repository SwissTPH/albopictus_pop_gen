#!/bin/bash
#SBATCH --job-name=LD_thinning
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --qos=30min
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/045_LD_thinning/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/045_LD_thinning/err_out/logs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

#load modules
module purge
module load PLINK/2.00a3.7-gfbf-2023a

#directories
OUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/045_LD_thinning
SCRIPT_DIR=/scicore/home/muellepi/marmor0000/git_repositories/albopictus_pop_gen/analysis_pipeline/python
VCF_IN=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/snp_filtering/031_test_thresholds/031_filter_FM_0.65_mD_3_MD_30/populations.snps.filter_FM_0.65_mD_3_MD_30.vcf.gz

#convert vcf to pgen file
plink2 --vcf $VCF_IN \
       --allow-extra-chr \
       --make-pgen \
       --out data

#LD pruning
plink2 --pfile data \
       --allow-extra-chr \
       --indep-pairwise 50 10 0.1 \
       --out pruned

#apply pruning
plink2 --pfile data \
       --allow-extra-chr \
       --extract pruned.prune.in \
       --make-pgen \
       --out data_pruned

#export vcf file
VCF_OUT=${OUT_DIR}/data_pruned

plink2 --pfile data_pruned \
       --allow-extra-chr \
       --export vcf \
       --out ${VCF_OUT}

#metrics of data_pruned.vcf are computed in 045_compute_metrics.sh, as VCFtools cannot be loaded together with PLINKv2.0
