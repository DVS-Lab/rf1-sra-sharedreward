import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class WorkdirContract(unittest.TestCase):
    def test_afni_helpers_canonicalize_requested_work_roots(self):
        for name in ("measure_smoothness.sh", "smooth_to_target.sh"):
            script = (ROOT / "code" / name).read_text()
            with self.subTest(script=name):
                self.assertIn(
                    'work_parent="$(cd "$requested_work" && pwd)"',
                    script,
                )
                self.assertIn('${work_parent}/', script)

    def test_target_smoothing_replaces_qc_atomically(self):
        script = (ROOT / "code/smooth_to_target.sh").read_text()
        self.assertIn('tmp_qc="$work/achieved-smoothness.tsv"', script)
        self.assertIn('--output-tsv "$tmp_qc"', script)
        self.assertIn('mv -f -- "$tmp_qc" "$qc"', script)

    def test_target_smoothing_can_use_all_blurmaster_subbricks(self):
        script = (ROOT / "code/smooth_to_target.sh").read_text()
        self.assertIn("--all-blurmaster", script)
        self.assertIn("blur_options+=(-bmall)", script)


if __name__ == "__main__":
    unittest.main()
