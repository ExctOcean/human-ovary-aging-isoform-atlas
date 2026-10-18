#!/usr/bin/env bash
set -Eeuo pipefail

# SQANTI3 6.0: all or qc.

cd "$(dirname "${BASH_SOURCE[0]}")/.."
SQ_SOURCE="${SQANTI3_DIR:?Set SQANTI3_DIR to the SQANTI3 6.0 source directory}"
SQ_PYTHON="${SQANTI3_PYTHON:-python}"
STAGE="${1:-all}"
if [[ "$STAGE" == all ]]; then
  cp "$SQ_SOURCE/src/utilities/filter/filter_default.json" preprocessing/sqanti3_filter_default.json
fi
"$SQ_PYTHON" "$SQ_SOURCE/sqanti3" "$STAGE" -c "preprocessing/sqanti3_${STAGE}.yaml"
