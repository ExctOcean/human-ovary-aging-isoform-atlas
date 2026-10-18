#!/usr/bin/env bash
set -Eeuo pipefail

# IsoQuant 4.0.0: transcript discovery.

cd "$(dirname "${BASH_SOURCE[0]}")/.."
SAMPLE=Sample01
IQ_PYTHON="${ISOQUANT_PYTHON:-python}"
IQ_SOURCE="${ISOQUANT_DIR:?Set ISOQUANT_DIR to the IsoQuant 4.0.0 source directory}"
export PYTHONPATH="$IQ_SOURCE${PYTHONPATH:+:$PYTHONPATH}"
export ISOQUANT_CONFIG_DIR="$PWD/output/isoquant-discovery/config"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 NUMEXPR_NUM_THREADS=1
mkdir -p "$ISOQUANT_CONFIG_DIR"

"$IQ_PYTHON" preprocessing/helpers/run_isoquant.py \
  --data_type nanopore --mode bulk \
  --bam "input/$SAMPLE.umi_representative.bam" \
  --labels "$SAMPLE" --read_group file_name \
  --illumina_bam "input/$SAMPLE.illumina.bam" \
  --reference reference/GRCh38.primary_assembly.genome.fa \
  --genedb reference/gencode.v50.annotation.gtf --complete_genedb \
  --analysis transcript_discovery quantification \
  --splice_correction_strategy default_ont --model_construction_strategy default_ont \
  --check_canonical --sqanti_output \
  --counts_format matrix --large_output read2transcripts \
  --threads 80 --prefix "$SAMPLE" --output output/isoquant-discovery
