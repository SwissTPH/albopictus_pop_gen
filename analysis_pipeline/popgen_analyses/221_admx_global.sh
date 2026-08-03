#!/bin/bash
#SBATCH --job-name=089_admixture_no_LIE_BGR
#SBATCH --mem=10G
#SBATCH --cpus-per-task=16
#SBATCH --time=12:00:00
#SBATCH --qos=1day
#SBATCH --output=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/Admixture/088_089_all_pops_no_LIE_BGR/err_out/admixture.%a.out
#SBATCH --error=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/Admixture/088_089_all_pops_no_LIE_BGR/err_out/admixture.%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=sarah.marmorosch@swisstph.ch
#SBATCH --array=1-20%10

# load module
module load ADMIXTURE

# run ADMIXTURE for K=1-20
K=$SLURM_ARRAY_TASK_ID

NUM_THREAD=16

# define directories
OUTPUT_DIR=/scicore/home/muellepi/marmor0000/albopictus_ddRADseq/popgen_analyses/Admixture/088_089_all_pops_no_LIE_BGR
INNAME=LD_thin_all_pops_no_LIE_BGR_num

cd ${OUTPUT_DIR}

# Summary file for this K
echo -e "K\tSeed\tLogLikelihood\tCV_Error" > ADMIXTURE_summary_K${K}.txt

# run ADMIXTURE for each K 10x (so that we can choose the one with the highest log-likelihood later 
for SEED in {1..11}
do

    echo "Running K=${K}, Seed=${SEED}"

    OUTFILE=LD_thin_all_pops_no_LIE_BGR.K${K}.seed${SEED}.output

    admixture \
        -j${NUM_THREAD} \
        --cv \
        --seed=${SEED} \
        ${INNAME}.bed ${K} \
        > ${OUTFILE}

    # Save Q and P files so they are not overwritten
    if [ -f "${INNAME}.${K}.Q" ]; then
        mv "${INNAME}.${K}.Q" "${INNAME}.K${K}.seed${SEED}.Q"
    fi

    if [ -f "${INNAME}.${K}.P" ]; then
        mv "${INNAME}.${K}.P" "${INNAME}.K${K}.seed${SEED}.P"
    fi

    # Extract CV error
    CV=$(grep "CV error" ${OUTFILE} | sed -E 's/CV error \(K=[0-9]+\): //')

    # Extract final log-likelihood
    LL=$(grep "Loglikelihood" ${OUTFILE} | tail -1 | awk '{print $2}')

    # Write summary
    echo -e "${K}\t${SEED}\t${LL}\t${CV}" >> ADMIXTURE_summary_K${K}.txt

done
