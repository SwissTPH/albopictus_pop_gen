#!/bin/bash
#SBATCH --job-name=demux_albo
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00
#SBATCH --qos=24hours
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/demultiplexed/err_out/logs.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/demultiplexed/err_out/log.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch

set -euo pipefail

module load Stacks/2.2-foss-2016b

# Paths
RAW_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/raw_data/
BARCODE_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/raw_data/barcodes/albo_1.txt
OUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/demultiplexed

process_radtags \
    -P \
    -p $RAW_DIR \
    -b ${BARCODE_DIR} \
    -o $OUT_DIR \
    -c -q -r \
    --inline_inline \
    --renz_1 nlaIII \
    --renz_2 mluCI \
    --filename-filter Final_albo_1

