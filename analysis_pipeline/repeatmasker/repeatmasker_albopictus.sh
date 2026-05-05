#!/bin/bash
#SBATCH --job-name=gff_repeats_albo
#SBATCH --cpus-per-task=32
#SBATCH --mem=256G
#SBATCH --time=14-00:00:00
#SBATCH --qos=2weeks
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/repeats_albo/ae_albopictus/err_out/repeats.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/repeats_albo/ae_albopictus/err_out/repeats.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

#define directories
BASEDIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/repeats_albo/
GENOME=${BASEDIR}/ae_albopictus_scaffolds.fa
OUTDIR=${BASEDIR}/ae_albopictus

#load module
module load RepeatMasker

RepeatMasker \
  -pa 32 \
  -engine rmblast \
  -species "aedes albopictus" \
  -xsmall \
  -gff \
  -dir ${OUTDIR} \
  ${GENOME}

