#!/usr/bin/env bash
set -Eeuo pipefail

# IsoQuant 4.0.0: CB/UB-tagged BAM quantification with scOvary.gtf.

cd "$(dirname "${BASH_SOURCE[0]}")/.."
SAMPLE=Sample01
IQ_PYTHON="${ISOQUANT_PYTHON:-python}"
IQ_SOURCE="${ISOQUANT_DIR:?Set ISOQUANT_DIR to the IsoQuant 4.0.0 source directory}"
OUT_DIR=output/isoquant
CATALOG=reference/scOvary.gtf
DATABASE="$OUT_DIR/database/scOvary.db"
export PYTHONPATH="$IQ_SOURCE${PYTHONPATH:+:$PYTHONPATH}"
export ISOQUANT_CONFIG_DIR="$PWD/$OUT_DIR/config/$SAMPLE"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 NUMEXPR_NUM_THREADS=1
mkdir -p "$OUT_DIR/database" "$ISOQUANT_CONFIG_DIR"

# Add gene records for database construction.
"$IQ_PYTHON" preprocessing/helpers/add_gene_records.py \
  "$CATALOG" "$OUT_DIR/database/scOvary.database_input.gtf"
"$IQ_PYTHON" "$IQ_SOURCE/isoquant_lib/gtf2db.py" \
  --input "$OUT_DIR/database/scOvary.database_input.gtf" \
  --output "$DATABASE" --mode gtf2db --complete_genedb

"$IQ_PYTHON" preprocessing/helpers/run_isoquant.py \
  --data_type nanopore --mode tenX_v3 \
  --bam "output/wf-single-cell/$SAMPLE/$SAMPLE.tagged.bam" \
  --barcoded_bam --barcode_tag CB --umi_tag UB --read_group barcode \
  --reference reference/GRCh38.primary_assembly.genome.fa \
  --genedb "$DATABASE" --analysis quantification \
  --counts_format mtx --large_output read_info \
  --threads 20 --prefix "$SAMPLE" --output "$OUT_DIR/$SAMPLE"
