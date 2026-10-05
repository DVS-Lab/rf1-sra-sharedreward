"""Synthetic integration tests; no production images or FEAT execution required."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import nibabel as nib
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("phase", ROOT / "code/phase_resolved_activation.py")
phase = importlib.util.module_from_spec(spec)
spec.loader.exec_module(phase)


class PhaseResolved(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.env = os.environ.copy()
        self.env.update({k: str(self.root / k) for k in
                         ("BIDS_ROOT", "HARMONIZED_ROOT", "CONFOUNDS_ROOT", "FSL_DERIVATIVES_ROOT")})
        self.env["TARGET_FWHM_MM"] = "6"
        self.p = phase.paths(("12345", "01", "1"), self.env)
        for path in self.p.values():
            path.parent.mkdir(parents=True, exist_ok=True)
        self.ref = nib.Nifti1Image(np.ones((3, 3, 3), dtype=np.float32), np.diag([2.7, 2.7, 2.97, 1]))
        bold = nib.Nifti1Image(np.ones((3, 3, 3, 64), dtype=np.float32), self.ref.affine)
        bold.header.set_zooms((2.7, 2.7, 2.97, 2.02))
        nib.save(bold, self.p["bold"])
        np.savetxt(self.p["confounds"], np.zeros((64, 1)))
        self.p["events"].write_text("onset\tduration\ttrial_type\n" + "".join(
            f"{i}\t0.5\t{label}\n" for i, label in enumerate(phase.LABELS) if i not in phase.OPTIONAL))
        self.contrasts = phase.contract()[1]
        fakebin = self.root / "bin"
        fakebin.mkdir()
        for name, output in (("fslnvols", "64 "), ("fslval", "2.020000 ")):
            script = fakebin / name
            script.write_text(f"#!/bin/sh\nprintf '%s\\n' '{output}'\n")
            script.chmod(0o755)
        self.env["PATH"] = str(fakebin) + os.pathsep + self.env["PATH"]

    def shell(self, script, *args, check=True):
        return subprocess.run(["bash", str(ROOT / "code" / script), *args],
                              env=self.env, text=True, capture_output=True, check=check)

    def render(self):
        self.shell("gen3colfiles.sh", "--subject", "12345", "--run", "1")
        self.shell("L1stats.sh", "12345", "1", "0", "--render-only")

    def maps(self, directory, numbers):
        (directory / "stats").mkdir(parents=True, exist_ok=True)
        nib.save(self.ref, directory / "mask.nii.gz")
        for number in numbers:
            for kind in ("cope", "varcope", "zstat"):
                nib.save(self.ref, directory / f"stats/{kind}{number}.nii.gz")

    def l1_fixture(self):
        self.render()
        self.p["feat"].mkdir()
        shutil.copyfile(self.p["rendered"], self.p["feat"] / "design.fsf")
        x = np.random.default_rng(1).normal(size=(64, 15))
        x[:, sorted(phase.OPTIONAL)] = 0
        self.write_matrix(self.p["feat"] / "design.mat", x)
        names = "".join(f"/ContrastName{i}\t{name}\n" for i, name, _ in self.contrasts)
        self.write_matrix(self.p["feat"] / "design.con",
                          np.array([np.pad(v, (0, 1)) for _, _, v in self.contrasts]), names)
        self.maps(self.p["feat"], [i for i, _, v in self.contrasts if not v[6:9].any()])

    @staticmethod
    def write_matrix(path, array, prefix=""):
        with path.open("w") as h:
            h.write(prefix + "/Matrix\n")
            np.savetxt(h, array)

    def test_frozen_contrasts_all_34_and_neutral_scope(self):
        signature = hashlib.sha256(json.dumps([(i, n, v.tolist()) for i, n, v in self.contrasts],
                                              separators=(",", ":")).encode()).hexdigest()
        self.assertEqual(signature, "3bcd0b20c36cb41f4d8121a613e7314a1b7eb0e6664e22d47a8a7e1208709929")
        self.assertEqual([i for i, _, v in self.contrasts if v[6:9].any()], [7, 8, 9, 20, 21, 22])

    def test_render_empty_neutral_and_misses_with_whitespace_tr(self):
        self.render()
        settings = phase.check_rendered(self.p["rendered"], self.p, self.contrasts)
        self.assertEqual(float(settings["fmri(tr)"]), 2.02)
        for i in phase.OPTIONAL:
            self.assertEqual(settings[f"fmri(shape{i+1})"], "10")
        for i in range(1, 15):
            self.assertEqual(settings[f"fmri(tempfilt_yn{i})"], "0")

    def test_present_neutral_and_misses_convolved(self):
        with self.p["events"].open("a") as h:
            h.write("".join(f"{20+i}\t0.5\t{phase.LABELS[i]}\n" for i in sorted(phase.OPTIONAL)))
        self.render()
        settings = phase.check_rendered(self.p["rendered"], self.p, self.contrasts)
        for i in range(1, 15):
            self.assertEqual(settings[f"fmri(shape{i})"], "3")
            self.assertEqual(settings[f"fmri(convolve{i})"], "3")

    def test_missing_substantive_condition_rejected(self):
        self.p["events"].write_text(self.p["events"].read_text().replace("event_friend_reward", "unused"))
        with self.assertRaisesRegex(ValueError, "Missing substantive"):
            phase.event_rows(self.p["events"])
        self.assertNotEqual(self.shell("gen3colfiles.sh", "--subject", "12345", "--run", "1", check=False).returncode, 0)

    def test_source_ev_mismatch_rejected(self):
        self.render()
        Path(f"{self.p['ev']}_{phase.LABELS[0]}.txt").write_text("50\t0.5\t1\n")
        with self.assertRaisesRegex(ValueError, "canonical phase timing"):
            phase.check_rendered(self.p["rendered"], self.p, self.contrasts)

    def test_actual_l1_design_and_maps(self):
        self.l1_fixture()
        phase.check_l1(self.p, self.contrasts, self.ref)
        path = self.p["feat"] / "design.con"
        path.write_text(path.read_text().replace("/ContrastName1\tC_pun", "/ContrastName1\tC_rew"))
        with self.assertRaisesRegex(ValueError, "name mismatch"):
            phase.check_l1(self.p, self.contrasts, self.ref)

    def test_changed_actual_contrast_rejected(self):
        self.l1_fixture()
        path = self.p["feat"] / "design.con"
        original = path.read_text()
        c = phase.matrix(path)
        c[0, 0] = 2
        self.write_matrix(path, c, original.split("/Matrix")[0])
        with self.assertRaisesRegex(ValueError, "Actual matrix differs"):
            phase.check_l1(self.p, self.contrasts, self.ref)

    def test_fsl_empty_neutral_zeroing_accepted_only_for_empty_neutral(self):
        self.l1_fixture()
        path = self.p["feat"] / "design.con"
        prefix = path.read_text().split("/Matrix")[0]
        c = phase.matrix(path)
        c[6:9] = 0
        self.write_matrix(path, c, prefix)
        self.assertEqual(phase.check_l1(self.p, self.contrasts, self.ref), [7, 8, 9])
        for index in (0, 19):  # Primary and mixed neutral hypotheses remain strict.
            altered = c.copy()
            altered[index] = 0
            self.write_matrix(path, altered, prefix)
            with self.assertRaisesRegex(ValueError, "Actual matrix differs"):
                phase.check_l1(self.p, self.contrasts, self.ref)
        self.write_matrix(path, c, prefix)
        design = self.p["feat"] / "design.mat"
        x = phase.matrix(design)
        x[:, 8] = np.arange(64)
        self.write_matrix(design, x)
        with self.assertRaisesRegex(ValueError, "Actual matrix differs: COPE9"):
            phase.check_l1(self.p, self.contrasts, self.ref)

    @unittest.skipUnless((Path(os.environ.get("FSLDIR", "/missing")) / "bin/feat_model").is_file(),
                         "FSL feat_model unavailable")
    def test_real_feat_model_empty_neutral_behavior(self):
        self.render()
        subprocess.run([str(Path(os.environ["FSLDIR"]) / "bin/feat_model"),
                        str(self.p["rendered"].with_suffix("")), str(self.p["confounds"])],
                       env=self.env, capture_output=True, text=True, check=True)
        self.p["feat"].mkdir()
        for source, target in ((self.p["rendered"], "design.fsf"),
                               (self.p["rendered"].with_suffix(".mat"), "design.mat"),
                               (self.p["rendered"].with_suffix(".con"), "design.con")):
            shutil.copyfile(source, self.p["feat"] / target)
        c = phase.matrix(self.p["feat"] / "design.con")
        self.assertTrue(np.all(c[6:9] == 0))
        self.maps(self.p["feat"], [i for i, _, v in self.contrasts if not v[6:9].any()])
        self.assertEqual(phase.check_l1(self.p, self.contrasts, self.ref), [7, 8, 9])

    def test_scoped_resume_checks_manifest_sources_and_stage(self):
        record = self.root / "logs/records/previous"
        record.mkdir(parents=True)
        keys = [("12345", "01", "1")]
        for name in ("L1-all.tsv", "L1-pilot.tsv"):
            phase.write_tsv(record / name, ["subject", "session", "run"], keys)
        sources = [phase.fingerprint(phase.TEMPLATE)]
        for relative in ("templates/CONTRAST_CROSSWALK.tsv", "code/L1stats.sh", "code/L2stats.sh"):
            path = self.root / relative
            path.parent.mkdir(exist_ok=True)
            path.write_text("original")
            sources.append(phase.fingerprint(path))
        event = self.p["events"]
        sources.append(phase.fingerprint(event))
        (record / "provenance.json").write_text(json.dumps(dict(
            model="RF1-phase-resolved-14EV-34cope", sources=sources, repo_commit="previous")))
        with patch.object(phase, "ROOT", self.root):
            self.assertEqual(phase.validate_pilot_resume(record, keys), (keys, "previous"))
            with self.assertRaisesRegex(ValueError, "manifest changed"):
                phase.validate_pilot_resume(record, [("99999", "01", "1")])
            (record / "pilot-passed.json").write_text("{}")
            with self.assertRaisesRegex(ValueError, "already passed"):
                phase.validate_pilot_resume(record, keys)
            (record / "pilot-passed.json").unlink()
            event.write_text(event.read_text() + "100\t1\tunused\n")
            with self.assertRaisesRegex(ValueError, "source changed"):
                phase.validate_pilot_resume(record, keys)

    def test_nonestimable_substantive_contrast_rejected(self):
        self.l1_fixture()
        path = self.p["feat"] / "design.mat"
        x = phase.matrix(path)
        x[:, 0] = 0
        self.write_matrix(path, x)
        with self.assertRaisesRegex(ValueError, "not estimable"):
            phase.check_l1(self.p, self.contrasts, self.ref)

    def test_bad_maps_rejected(self):
        directory = self.root / "maps"
        for problem in ("missing", "grid", "nonfinite", "variance"):
            with self.subTest(problem=problem):
                self.maps(directory, [1])
                path = directory / "stats/varcope1.nii.gz"
                if problem == "missing":
                    path.unlink()
                else:
                    data = np.ones((3, 3, 3))
                    affine = self.ref.affine.copy()
                    if problem == "grid":
                        affine[0, 3] += 1
                    if problem == "nonfinite":
                        data[0, 0, 0] = np.nan
                    if problem == "variance":
                        data[:] = 0
                    nib.save(nib.Nifti1Image(data, affine), path)
                with self.assertRaises((ValueError, FileNotFoundError)):
                    phase.check_maps(directory, [1], self.ref)

    def test_l2_fixed_effects_and_parent_order(self):
        directory = self.p["l2"]
        directory.mkdir()
        parents = [self.root / "run1.feat", self.root / "run2.feat"]
        fsf = (ROOT / "templates/L2_task-sharedreward_model-1_type-act.fsf").read_text()
        fsf = fsf.replace("INPUT1", str(parents[0])).replace("INPUT2", str(parents[1]))
        (directory / "design.fsf").write_text(fsf)
        for i, _, v in self.contrasts:
            if not v[6:9].any():
                child = directory / f"cope{i}.feat"
                self.maps(child, [1])
                self.write_matrix(child / "design.mat", np.ones((2, 1)))
                self.write_matrix(child / "design.con", np.ones((1, 1)))
        phase.check_l2(directory, parents, self.contrasts, self.ref)
        with self.assertRaisesRegex(ValueError, "parents/order"):
            phase.check_l2(directory, parents[::-1], self.contrasts, self.ref)
        (directory / "design.fsf").write_text(fsf.replace("set fmri(mixed_yn) 3", "set fmri(mixed_yn) 2"))
        with self.assertRaisesRegex(ValueError, "mixed_yn"):
            phase.check_l2(directory, parents, self.contrasts, self.ref)

    def test_manifest_duplicates_and_malformed_rows(self):
        path = self.root / "manifest.tsv"
        header = "subject\tsession\trun\n"
        for body in ("", "12345\t01\t1\n12345\t01\t1\n", "12345\t01\t3\n", "12345\t01\n"):
            path.write_text(header + body)
            with self.assertRaises(ValueError):
                phase.read_manifest(path)
        path.write_text(header + "12345\t01\t2\n12345\t01\t1\n")
        self.assertEqual(phase.read_manifest(path), [("12345", "01", "1"), ("12345", "01", "2")])


if __name__ == "__main__":
    unittest.main()
