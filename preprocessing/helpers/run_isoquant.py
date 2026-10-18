#!/usr/bin/env python3
"""Run IsoQuant with a specified configuration directory."""

from __future__ import annotations

import json
import os
from pathlib import Path

import isoquant


def set_project_config_directory(args) -> None:
    value = os.environ.get("ISOQUANT_CONFIG_DIR")
    if not value:
        raise RuntimeError("ISOQUANT_CONFIG_DIR is not set")
    directory = Path(value).resolve()
    directory.mkdir(parents=True, exist_ok=True)
    paths = {
        "db_config_path": directory / "db_config.json",
        "index_config_path": directory / "index_config.json",
        "bed_config_path": directory / "bed_config.json",
        "alignment_config_path": directory / "alignment_config.json",
    }
    for attribute, path in paths.items():
        setattr(args, attribute, str(path))
        if not path.exists():
            path.write_text(json.dumps({}, indent=2) + "\n", encoding="utf-8")


isoquant.set_configs_directory = set_project_config_directory

if __name__ == "__main__":
    isoquant.main_entry()
