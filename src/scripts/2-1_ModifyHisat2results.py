
#!/usr/bin/env python3
# summarize_hisat.py
# Summarize HISAT2 alignment results from a single log file.

import re
import csv
from pathlib import Path

# Directories
PROJECT = Path(__file__).resolve().parent.parent
ALIGN_DIR = PROJECT / "2_align"

INPUT = ALIGN_DIR / "hisat_results.txt"
OUTPUT = ALIGN_DIR / "hisat_summary.tsv"

EXPECTED_SAMPLES = 6

# Read log
text = INPUT.read_text(errors="replace")

results = {}

# Split log into sample-specific blocks
blocks = re.split(r"(?=^# start\s+)", text, flags=re.MULTILINE)

for block in blocks:

    if not block.strip():
        continue

    # Sample name
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

    # Extract alignment counts
    patterns = {
        "read number": r"^\s*(\d+) reads; of these:",
        "paired reads": r"^\s*(\d+) \([\d.]+%\) aligned concordantly exactly 1 time",
        "paired multi": r"^\s*(\d+) \([\d.]+%\) aligned concordantly >1 times",
        "discordantly": r"^\s*(\d+) \([\d.]+%\) aligned discordantly 1 time",
        "aligned 0 time": r"^\s*(\d+) \([\d.]+%\) aligned 0 times",
        "exactly 1 times": r"^\s*(\d+) \([\d.]+%\) aligned exactly 1 time",
        "> 1 time": r"^\s*(\d+) \([\d.]+%\) aligned >1 times",
        "over all alignment rate": r"^\s*([\d.]+%) overall alignment rate",
    }

    sample_result = {}
    missing = []

    for label, pattern in patterns.items():
        match = re.search(pattern, block, flags=re.MULTILINE)

        if match:
            value = match.group(1)
            sample_result[label] = (
                value if label == "over all alignment rate"
                else int(value)
            )
        else:
            missing.append(label)

    if missing:
        print(
            f"WARNING: Missing alignment data for {sample}: "
            + ", ".join(missing)
        )
        continue

    if sample in results:
        raise ValueError(f"Duplicate sample ID: {sample}")

    results[sample] = sample_result

# Sort samples
samples = sorted(results)

# Output rows
row_names = [
    "read number",
    "paired reads",
    "paired multi",
    "discordantly",
    "aligned 0 time",
    "exactly 1 times",
    "> 1 time",
    "over all alignment rate",
]

# Write TSV
with OUTPUT.open("w", newline="") as f:
    writer = csv.writer(f, delimiter="\t")

    writer.writerow(["Sample name"] + samples)

    for row in row_names:
        writer.writerow(
            [row] + [results[s][row] for s in samples]
        )

print(f"Processed {len(samples)} samples.")
print(f"Output: {OUTPUT}")

if len(samples) != EXPECTED_SAMPLES:
    print(
        f"WARNING: Expected {EXPECTED_SAMPLES} samples, "
        f"found {len(samples)}."
    )
