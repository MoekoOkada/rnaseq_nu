#!/bin/sh
# 2_map.sh
# Project: SummerSchool
# Date: 4-Jul-2023
# Author: Moeko Okada

mkdir 2_map
cd 1_qc/


for i in `ls *_R1_pair.fastq.gz`; do
  f=`basename ${i} _R1_pair.fastq.gz`
  echo "# start ${f} "

  hisat2 -p 2 -x ../genome/AthTAIR10 -1 ${i} -2 ${f}_R2_pair.fastq.gz | samtools view -SbF4 -q 40 - | samtools sort -m 8G -@ 2 -o ../2_map/${f}.bam
  samtools index ../2_map/${f}.bam

  echo "# done ${f} " $(date)
done
