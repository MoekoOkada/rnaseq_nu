#!/bin/sh
# 1_qc.sh
# Project: SummerSchool
# Date: 4-Jul-2023
# Author: Moeko Okada

mkdir 1_qc
cd fastq/

for i in `ls *_R1.fastq.gz`; do
  f=`basename ${i} _R1.fastq.gz`
  echo "# start ${f} "

  trimmomatic PE -phred33 -threads 2 \
    ${i} ${f}_R2.fastq.gz \
    ../1_qc/${f}_R1_pair.fastq.gz ../1_qc/${f}_R1_unpair.fastq.gz \
    ../1_qc/${f}_R2_pair.fastq.gz ../1_qc/${f}_R2_unpair.fastq.gz \
    ILLUMINACLIP:../TruSeq-PE-all.fa:2:30:10 \
    SLIDINGWINDOW:4:30 MINLEN:50

  echo "# done ${f} " $(date)
done
