#!/bin/bash
# 1_qc.sh
# Project: RNAseq_NU
# Tool: fastp
# Author: Moeko Okada

mkdir -p 1_qc
cd fastq/ || exit 1

for i in *_R1.fastq.gz; do
    f="${i%_R1.fastq.gz}"
    echo "# start ${f} $(date)"

    fastp \
        -i "${f}_R1.fastq.gz" \
        -I "${f}_R2.fastq.gz" \
        -o "../1_qc/${f}_R1_pair.fastq.gz" \
        -O "../1_qc/${f}_R2_pair.fastq.gz" \
        --detect_adapter_for_pe \
        --cut_right \
        --cut_right_window_size 4 \
        --cut_right_mean_quality 30 \
        --length_required 50 \
        --thread 2 \
        --html "../1_qc/${f}_fastp.html" \
        --json "../1_qc/${f}_fastp.json"

    echo "# done ${f} $(date)"
done
