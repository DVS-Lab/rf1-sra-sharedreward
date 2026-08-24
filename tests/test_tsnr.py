import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class Tsnr(unittest.TestCase):
    def test_reference_mask_defines_coverage_and_summary_domain(self):
        try:
            import nibabel as nib
            import numpy as np
        except ImportError:
            self.skipTest("nibabel unavailable")
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            affine = np.eye(4)
            data = np.zeros((2, 2, 1, 3), dtype=np.float32)
            data[0, 0, 0, :] = [1, 2, 3]
            data[0, 1, 0, :] = [2, 4, 6]
            data[1, 0, 0, :] = [4, 4, 4]
            bold = directory / "bold.nii.gz"
            run_mask = directory / "run-mask.nii.gz"
            reference = directory / "reference-mask.nii.gz"
            nib.save(nib.Nifti1Image(data, affine), bold)
            nib.save(
                nib.Nifti1Image(
                    np.array([[[1], [1]], [[0], [0]]], dtype=np.uint8), affine
                ),
                run_mask,
            )
            nib.save(
                nib.Nifti1Image(
                    np.array([[[1], [1]], [[1], [1]]], dtype=np.uint8), affine
                ),
                reference,
            )
            output = directory / "tsnr.json"
            result = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "code/compute_tsnr.py"),
                    "--input",
                    str(bold),
                    "--mask",
                    str(run_mask),
                    "--reference-mask",
                    str(reference),
                    "--output-json",
                    str(output),
                ],
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            summary = json.loads(output.read_text())
            self.assertEqual(summary["run_mask_voxels"], 2)
            self.assertEqual(summary["reference_mask_voxels"], 4)
            self.assertEqual(summary["analysis_mask_voxels"], 2)
            self.assertEqual(summary["valid_voxels"], 2)
            self.assertEqual(summary["coverage_pct"], 50.0)
            self.assertEqual(summary["valid_coverage_pct"], 50.0)
            self.assertAlmostEqual(summary["median_tsnr"], 2.0)


if __name__ == "__main__":
    unittest.main()
