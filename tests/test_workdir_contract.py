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


if __name__ == "__main__":
    unittest.main()
