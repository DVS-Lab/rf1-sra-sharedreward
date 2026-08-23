import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path

import nibabel as nib
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "audit_rf1_grid", ROOT / "code/audit_rf1_grid.py"
)
assert SPEC is not None and SPEC.loader is not None
AUDIT = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = AUDIT
SPEC.loader.exec_module(AUDIT)


def save_bold(root, subject, run, affine, code):
    directory = root / f"sub-{subject}" / "ses-01" / "func"
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / (
        f"sub-{subject}_ses-01_task-sharedreward_run-{run}_part-mag_"
        "space-MNI152NLin6Asym_desc-preproc_bold.nii.gz"
    )
    image = nib.Nifti1Image(np.ones((3, 4, 5, 2), dtype=np.float32), affine)
    image.set_qform(affine, code=code)
    image.set_sform(affine, code=code)
    nib.save(image, path)
    return path


class GridAuditTest(unittest.TestCase):
    def test_signed_zero_is_one_grid_but_codes_remain_a_gate(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "fmriprep"
            modal = np.diag([2.7, 2.7, 2.97, 1.0])
            signed_zero = modal.copy()
            signed_zero[0, 2] = -0.0
            save_bold(root, "11001", "1", modal, 4)
            save_bold(root, "12013", "1", signed_zero, 1)
            output = Path(directory) / "audit"

            self.assertEqual(AUDIT.run(root, output, 1e-5), 1)
            report = json.loads(output.with_suffix(".json").read_text())
            self.assertEqual(report["n_unique_grids"], 1)
            self.assertEqual(report["n_xform_metadata_mismatches"], 1)

    def test_conformant_metadata_passes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "fmriprep"
            affine = np.diag([2.7, 2.7, 2.97, 1.0])
            save_bold(root, "11001", "1", affine, 4)
            save_bold(root, "11002", "1", affine, 4)
            output = Path(directory) / "audit"

            self.assertEqual(AUDIT.run(root, output, 1e-5), 0)
            report = json.loads(output.with_suffix(".json").read_text())
            self.assertEqual(report["n_unique_grids"], 1)
            self.assertEqual(report["n_xform_metadata_mismatches"], 0)


if __name__ == "__main__":
    unittest.main()
