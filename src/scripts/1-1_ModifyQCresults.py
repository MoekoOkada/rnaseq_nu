#!/usr/bin/env python3
# summarize_qc.py
# Summarize multiple fastp QC results from a single log file.

import re
import csv
from pathlib import Path

# Directories
PROJECT = Path(__file__).resolve().parent.parent
QC_DIR = PROJECT / "1_qc"

INPUT = QC_DIR / "qc_results.txt"
OUTPUT = QC_DIR / "qc_summary.tsv"

EXPECTED_SAMPLES = 6

# Read log
text = INPUT.read_text(errors="replace")

results = {}

# Split log into sample-specific blocks
blocks = re.split(r"(?=^# start\s+)", text, flags=re.MULTILINE)

for block in blocks:

    if not block.strip():
        continue

    # Sample name from "# start sample_name ..."
    sample_match = re.search(
        r"^# start\s+(\S+)",
        block,
        flags=re.MULTILINE
    )

    if not sample_match:
        print("WARNING: Sample name not found. Skipping block.")
        continue

    sample = sample_match.group(1)

    # Check whether processing completed
    done_match = re.search(
        rf"^# done\s+{re.escape(sample)}(?:\s|$)",
        block,
        flags=re.MULTILINE
    )

    if not done_match:
        print(f"WARNING: Incomplete log for {sample}. Skipping.")
        continue

    # Read counts before filtering
    r1_match = re.search(
        r"Read1 before filtering:\s*total reads:\s*(\d+)",
        block
    )
    r2_match = re.search(
        r"Read2 before filtering:\s*total reads:\s*(\d+)",
        block
    )

    # Reads passed filter
    filter_match = re.search(
        r"reads passed filter:\s*(\d+)",
        block
    )

    # Check missing values
    if not all([r1_match, r2_match, filter_match]):
        print(f"WARNING: Missing QC data for {sample}. Skipping.")
        continue

    if sample in results:
        raise ValueError(f"Duplicate sample ID: {sample}")

    total = int(r1_match.group(1)) + int(r2_match.group(1))
    filtered = int(filter_match.group(1))

    results[sample] = {
        "Total": total,
        "Filter": filtered
    }

# Sort samples
samples = sorted(results)

# Write TSV
with OUTPUT.open("w", newline="") as f:
    writer = csv.writer(f, delimiter="\t")

    writer.writerow(["Sample"] + samples)
    writer.writerow(["Total"] + [results[s]["Total"] for s in samples])
    writer.writerow(["Filter"] + [results[s]["Filter"] for s in samples])

print(f"Processed {len(samples)} samples.")
print(f"Output: {OUTPUT}")

if len(samples) != EXPECTED_SAMPLES:
    print(
        f"WARNING: Expected {EXPECTED_SAMPLES} samples, "
        f"found {len(samples)}."
    )