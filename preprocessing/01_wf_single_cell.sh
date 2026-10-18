#!/usr/bin/env bash
set -Eeuo pipefail

# wf-single-cell v3.3.4; GENCODE v50.
# Reference layout: fasta/genome.fa and genes/genes.gtf.

cd "$(dirname "${BASH_SOURCE[0]}")/.."
export NXF_VER=25.04.8

nextflow run epi2me-labs/wf-single-cell \
  -r v3.3.4 \
  -profile singularity \
  -work-dir work/wf-single-cell \
  -resume \
  --fastq input_fastq \
  --kit '3prime:v3' \
  --expected_cells 8000 \
  --ref_genome_dir reference/wf_gencodeV50 \
  --out_dir output/wf-single-cell
