#!/bin/bash
#SBATCH --job-name=demux_albo
#SBATCH --mem=20G
#SBATCH --cpus-per-task=6
#SBATCH --time=7-00:00:00
#SBATCH --qos=1week
#SBATCH --array=1-5%5
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/cleaned/err_out/demux_%a.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/cleaned/err_out/demux_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

module load Stacks/2.2-foss-2016b

# Paths
RAW_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/raw_data
BARCODE_DIR=${RAW_DIR}/barcodes
OUT_BASE=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/cleaned

# Map SLURM array index → library name
LIBS=(Final_albo_1 Final_albo_2 Final_albo_3 Final_albo_4 Final_albo_5)

LIB=${LIBS[$SLURM_ARRAY_TASK_ID-1]}

OUT_DIR=${OUT_BASE}

process_radtags \
    -P \
    -p $RAW_DIR \
    -b ${BARCODE_DIR}/albo_${SLURM_ARRAY_TASK_ID}.txt \
    -o $OUT_DIR \
    -c -q -r \
    --inline_inline \
    --renz_1 nlaIII \
    --renz_2 mluCI \
    --filename-filter $LIB

