#!/usr/bin/env python3
"""Add explicit gene records for the IsoQuant database; preserve transcript/exon records."""

from __future__ import annotations

import argparse
from collections import OrderedDict
from pathlib import Path


def attrs(text: str) -> dict[str, str]:
    out = {}
    fields = text.rstrip(";").split("; ")
    for field in fields:
        if " " not in field:
            continue
        key, value = field.split(" ", 1)
        out[key] = value.strip().strip('"')
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    genes: OrderedDict[str, dict] = OrderedDict()
    with args.input.open(encoding="utf-8") as fh:
        for line in fh:
            if line.startswith("#"):
                continue
            f = line.rstrip("\n").split("\t")
            if len(f) != 9 or f[2] != "transcript":
                continue
            a = attrs(f[8])
            gid = a.get("gene_id")
            if not gid:
                raise ValueError("transcript without gene_id")
            record = genes.setdefault(gid, {"chrom": f[0], "source": "scOvary_db", "start": int(f[3]), "end": int(f[4]), "strand": f[6], "gene_name": a.get("gene_name", "")})
            if record["chrom"] != f[0] or record["strand"] != f[6]:
                raise ValueError(f"gene spans incompatible loci: {gid}")
            record["start"] = min(record["start"], int(f[3]))
            record["end"] = max(record["end"], int(f[4]))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8") as out:
        out.write("# scOvary annotation with gene records.\n")
        for gid, r in sorted(genes.items(), key=lambda x: (x[1]["chrom"], x[1]["start"], x[0])):
            name = r["gene_name"] or gid
            out.write(f'{r["chrom"]}\t{r["source"]}\tgene\t{r["start"]}\t{r["end"]}\t.\t{r["strand"]}\t.\tgene_id "{gid}"; gene_name "{name}";\n')
        with args.input.open(encoding="utf-8") as fh:
            for line in fh:
                if line.startswith("#"):
                    continue
                out.write(line)
    print(f"wrote {len(genes)} gene rows to {args.output}")


if __name__ == "__main__":
    main()
