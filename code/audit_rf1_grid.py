#!/usr/bin/env python3
"""Audit RF1 Shared Reward BOLD grids and qform/sform metadata."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path

import numpy as np


DEFAULT_AFFINE_ATOL = 1e-5


def signature(image):
    import nibabel as nib

    qform = image.get_qform()
    sform = image.get_sform()
    qform_code = int(image.header["qform_code"])
    sform_code = int(image.header["sform_code"])
    return {
        "shape": list(image.shape[:3]),
        "zooms": [float(value) for value in image.header.get_zooms()[:3]],
        "orientation": "".join(nib.aff2axcodes(image.affine)),
        "affine": np.asarray(image.affine, dtype=float).tolist(),
        "qform_code": qform_code,
        "sform_code": sform_code,
        "qform": np.asarray(qform, dtype=float).tolist(),
        "sform": np.asarray(sform, dtype=float).tolist(),
    }


def spatial_grid_matches(left, right, atol):
    return left["shape"] == right["shape"] and bool(
        np.allclose(left["affine"], right["affine"], rtol=0.0, atol=atol)
    )


def xform_metadata_matches(left, right, atol):
    return (
        left["qform_code"] == right["qform_code"]
        and left["sform_code"] == right["sform_code"]
        and bool(
            np.allclose(left["qform"], right["qform"], rtol=0.0, atol=atol)
        )
        and bool(
            np.allclose(left["sform"], right["sform"], rtol=0.0, atol=atol)
        )
    )


def cluster_spatial_grids(records, atol):
    clusters = []
    for record in records:
        for cluster in clusters:
            if spatial_grid_matches(record, cluster[0], atol):
                cluster.append(record)
                break
        else:
            clusters.append([record])
    clusters.sort(key=lambda cluster: (-len(cluster), cluster[0]["path"]))
    if len(clusters) > 1 and len(clusters[0]) == len(clusters[1]):
        raise ValueError("spatial-grid mode is tied; refusing to choose a reference")
    return clusters


def run(fmriprep_root: Path, output_prefix: Path, affine_atol: float) -> int:
    try:
        import nibabel as nib
    except ImportError as exc:
        raise ValueError(f"nibabel is required: {exc}") from exc

    files = sorted(
        fmriprep_root.glob(
            "sub-*/ses-*/func/"
            "sub-*_ses-*_task-sharedreward_run-*_part-mag_"
            "space-MNI152NLin6Asym_desc-preproc_bold.nii.gz"
        )
    )
    if not files:
        raise ValueError("no canonical Shared Reward BOLD files found")

    records = [
        {"path": str(path.resolve()), **signature(nib.load(path, mmap=True))}
        for path in files
    ]
    clusters = cluster_spatial_grids(records, affine_atol)
    modal = clusters[0][0]
    modal_count = len(clusters[0])
    metadata_mismatches = 0
    for record in records:
        record["matches_modal"] = spatial_grid_matches(
            record, modal, affine_atol
        )
        record["xform_metadata_matches_modal"] = (
            record["matches_modal"]
            and xform_metadata_matches(record, modal, affine_atol)
        )
        if record["matches_modal"] and not record["xform_metadata_matches_modal"]:
            metadata_mismatches += 1

    output_prefix.parent.mkdir(parents=True, exist_ok=True)
    json_path = output_prefix.with_suffix(".json")
    tsv_path = output_prefix.with_suffix(".tsv")
    payload = {
        "n_files": len(files),
        "affine_atol": affine_atol,
        "n_unique_grids": len(clusters),
        "modal_count": modal_count,
        "n_xform_metadata_mismatches": metadata_mismatches,
        "modal_grid": {
            key: modal[key]
            for key in (
                "shape",
                "zooms",
                "orientation",
                "affine",
                "qform_code",
                "sform_code",
                "qform",
                "sform",
            )
        },
        "files": records,
    }
    json_path.write_text(json.dumps(payload, indent=2) + "\n")
    with tsv_path.open("w", newline="") as handle:
        writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
        writer.writerow(
            [
                "path",
                "shape",
                "zooms",
                "orientation",
                "qform_code",
                "sform_code",
                "matches_modal",
                "xform_metadata_matches_modal",
            ]
        )
        for record in records:
            writer.writerow(
                [
                    record["path"],
                    "x".join(map(str, record["shape"])),
                    "x".join(map(str, record["zooms"])),
                    record["orientation"],
                    record["qform_code"],
                    record["sform_code"],
                    str(record["matches_modal"]).lower(),
                    str(record["xform_metadata_matches_modal"]).lower(),
                ]
            )

    print(f"Files: {len(files)}")
    print(f"Unique spatial grids: {len(clusters)}")
    print(f"Modal grid files: {modal_count}")
    print(f"qform/sform metadata mismatches: {metadata_mismatches}")
    print(f"JSON: {json_path}")
    print(f"TSV: {tsv_path}")
    return 0 if len(clusters) == 1 and metadata_mismatches == 0 else 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fmriprep-root", required=True, type=Path)
    parser.add_argument("--output-prefix", required=True, type=Path)
    parser.add_argument("--affine-atol", type=float, default=DEFAULT_AFFINE_ATOL)
    args = parser.parse_args()
    if args.affine_atol <= 0:
        parser.error("--affine-atol must be positive")
    try:
        return run(args.fmriprep_root, args.output_prefix, args.affine_atol)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    raise SystemExit(main())
