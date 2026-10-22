#!/bin/bash
# 1_qc.sh
# Project: RNAseq_NU
# Tool: fastp
# Author: Moeko Okada

mkdir -p 1_qc
cd fastq/ || exit 1

for file in *_R1.fastq.gz; do
    sample="${file%_R1.fastq.gz}"
    echo "# start ${sample} $(date)"

    fastp \
        -i "${sample}_R1.fastq.gz" \
        -I "${sample}_R2.fastq.gz" \
        -o "../1_qc/${sample}_R1_pair.fastq.gz" \
        -O "../1_qc/${sample}_R2_pair.fastq.gz" \
        --detect_adapter_for_pe \
        --cut_right \
        --cut_right_window_size 4 \
        --cut_right_mean_quality 30 \
        --length_required 50 \
        --thread 2 \
        --html "../1_qc/${sample}_fastp.html" \
        --json "../1_qc/${sample}_fastp.json"

    echo "# done ${sample} $(date)"
done
