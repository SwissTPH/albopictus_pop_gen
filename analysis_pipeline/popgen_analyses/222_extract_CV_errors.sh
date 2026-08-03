#!/bin/bash

OUTPUT="CV_error.txt"

echo -e "K\tSeed\tLogLikelihood\tCV_Error" > ${OUTPUT}

for FILE in ADMIXTURE_summary_K*.txt
do
    BEST_LINE=$(awk 'NR>1' "${FILE}" | sort -k3,3nr | head -n 1)

    echo "${BEST_LINE}" >> ${OUTPUT}
done
