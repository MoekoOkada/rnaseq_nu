#!/bin/sh
# 4_count.sh
# Project: SummerSchool
# Date: 4-Jul-2023
# Author: Moeko Okada

mkdir 3_count
cd 2_map/


featureCounts -p -T 2 -t transcript -g transcript_id -a ../genome/AthTAIR10.gtf -o ../3_count/counts.txt $(ls *.bam)
