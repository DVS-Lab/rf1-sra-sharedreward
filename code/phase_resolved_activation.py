#!/usr/bin/env python3
"""First-production RF1 activation: preflight, audited pilot, L1 batch, fixed effects.

Consumes an explicit RF1 subject/session/run manifest. No cohort selection,
PPI, pooled models, source edits, or overwriting existing FEAT directories.
"""
import argparse
import csv
import hashlib
import io
import json
import os
import re
import shutil
import subprocess
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

import nibabel as nib
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "templates/L1_task-sharedreward_model-1_type-act.fsf"
LABELS = [f"event_{p}_{o}" for p in ("computer", "friend", "stranger")
          for o in ("punish", "reward")]
LABELS += [f"event_{p}_neutral" for p in ("computer", "friend", "stranger")]
LABELS += ["missed_decision", "missed_outcome", "friend_face", "stranger_face", "computer_non-face"]
TITLES = ["C_pun", "C_rew", "F_pun", "F_rew", "S_pun", "S_rew", "C_neu", "F_neu", "S_neu",
          "missed_decision", "missed_outcome", "F_dec", "S_dec", "C_dec"]
OPTIONAL = set(range(6, 11))


def require(condition, message):
    if not condition:
        raise ValueError(message)


def settings(path):
    return {k: v.strip().strip('"') for k, v in re.findall(
        r"^set\s+(\S+)\s+([^\n]+)", path.read_text(), re.M)}


def contract():
    s = settings(TEMPLATE)
    require([s[f"fmri(evtitle{i})"] for i in range(1, 15)] == TITLES, "EV ordering changed")
    with (ROOT / "templates/CONTRAST_CROSSWALK.tsv").open() as h:
        crosswalk = list(csv.DictReader(h, delimiter="\t"))
    require(len(crosswalk) == 34, "Expected 34 authoritative contrasts")
    result = []
    for i, row in enumerate(crosswalk, 1):
        name = s[f"fmri(conname_real.{i})"]
        vector = np.array([float(s[f"fmri(con_real{i}.{j})"]) for j in range(1, 15)])
        require(int(row["authoritative_cope"]) == i and row["contrast_name"] == name,
                f"Crosswalk/template name or numbering differs: COPE{i}")
        require(not vector[9:11].any(), "Miss nuisance contributes to a contrast")
        result.append((i, name, vector))
    return s, result


def read_manifest(path):
    with path.open() as h:
        reader = csv.DictReader(h, delimiter="\t")
        require(reader.fieldnames == ["subject", "session", "run"], "Expected subject/session/run header")
        rows = list(reader)
    require(rows, "Empty manifest")
    keys = []
    for r in rows:
        require(None not in r and all(r.get(k) for k in ("subject", "session", "run")), "Malformed row")
        require(re.fullmatch(r"\d+", r["subject"]) and re.fullmatch(r"\d{2}", r["session"])
                and r["run"] in ("1", "2"), f"Invalid unit: {r}")
        keys.append(tuple(r[k] for k in ("subject", "session", "run")))
    require(len(keys) == len(set(keys)), "Duplicate manifest units")
    return sorted(keys)


def paths(key, env):
    sub, ses, run = key
    stem = f"sub-{sub}_ses-{ses}_task-sharedreward_run-{run}"
    fsl = Path(env["FSL_DERIVATIVES_ROOT"])
    directory = fsl / f"sub-{sub}" / f"ses-{ses}"
    return dict(
        events=Path(env["BIDS_ROOT"]) / f"sub-{sub}/ses-{ses}/func/{stem}_events.tsv",
        bold=Path(env["HARMONIZED_ROOT"]) / f"sub-{sub}/ses-{ses}/func/{stem}_space-MNI152NLin6Asym_desc-smoothToFWHM6_bold.nii.gz",
        confounds=Path(env["CONFOUNDS_ROOT"]) / f"sub-{sub}/{stem}_desc-TedanaPlusConfounds.tsv",
        ev=fsl / f"EVfiles/sub-{sub}/ses-{ses}/sharedreward/run-{run}",
        feat=directory / f"L1_task-sharedreward_ses-{ses}_model-1_type-act_run-{run}_smTo-6.feat",
        rendered=directory / f"L1_sub-{sub}_task-sharedreward_ses-{ses}_model-1_type-act_run-{run}.fsf",
        l2=directory / f"L2_task-sharedreward_ses-{ses}_model-1_type-act_smTo-6.gfeat")


def event_rows(path):
    result = defaultdict(list)
    with path.open() as h:
        reader = csv.DictReader(h, delimiter="\t")
        require({"onset", "duration", "trial_type"} <= set(reader.fieldnames or []), "Invalid event header")
        for row in reader:
            onset, duration = float(row["onset"]), float(row["duration"])
            require(np.isfinite([onset, duration]).all() and onset >= 0 and duration >= 0, "Invalid event timing")
            result[row["trial_type"]].append([onset, duration, 1.])
    for i, label in enumerate(LABELS):
        require(i in OPTIONAL or result[label], f"Missing substantive event category: {label} in {path}")
    return result


def matrix(path):
    content = path.read_text()
    require("/Matrix" in content, f"No matrix: {path}")
    return np.loadtxt(io.StringIO(content.split("/Matrix", 1)[1]), ndmin=2)


def check_rendered(path, p, contrasts):
    s = settings(path)
    for k, value in {"level": 1, "evs_orig": 14, "evs_real": 14, "ncon_real": 34,
                     "ncon_orig": 34, "smooth": 0, "featwatcher_yn": 0,
                     "prewhiten_yn": 1, "regstandard_yn": 0, "paradigm_hp": 200,
                     "conmask1_1": 0}.items():
        require(float(s[f"fmri({k})"]) == value, f"Wrong {k}: {path}")
    for key, wanted in (("feat_files(1)", p["bold"]), ("confoundev_files(1)", p["confounds"])):
        require(Path(s[key]).resolve() == wanted.resolve(), f"Wrong {key}")
    expected = event_rows(p["events"])
    for i, label in enumerate(LABELS, 1):
        ev = Path(s[f"fmri(custom{i})"])
        require(ev.resolve() == Path(f"{p['ev']}_{label}.txt").resolve(), f"Wrong EV path {i}")
        wanted = np.array(expected[label]).reshape(-1, 3)
        actual = np.loadtxt(ev, ndmin=2) if ev.stat().st_size else np.empty((0, 3))
        require(actual.shape == wanted.shape and np.allclose(actual, wanted, atol=1e-6, rtol=0),
                f"EV {i} does not match canonical phase timing")
        require(s[f"fmri(evtitle{i})"] == TITLES[i-1], f"Wrong EV title {i}")
        require(int(s[f"fmri(shape{i})"]) == (3 if len(wanted) else 10), f"Wrong EV shape {i}")
        for field, value in (("convolve", 3), ("tempfilt_yn", 0), ("deriv_yn", 0)):
            require(int(s[f"fmri({field}{i})"]) == value, f"Wrong {field}{i}")
    for number, name, vector in contrasts:
        for mode in ("real", "orig"):
            require(s[f"fmri(conname_{mode}.{number})"] == name, f"Wrong COPE{number} name")
            actual = [float(s[f"fmri(con_{mode}{number}.{i})"]) for i in range(1, 15)]
            require(np.allclose(actual, vector, atol=1e-8, rtol=0), f"Wrong COPE{number} vector")
    return s


def check_maps(directory, numbers, reference):
    def values(path):
        image = nib.load(str(path))
        require(image.shape == reference.shape[:3] and np.allclose(image.affine, reference.affine, atol=1e-4, rtol=0),
                f"Map/grid mismatch: {path}")
        data = image.get_fdata(dtype=np.float32)
        require(np.isfinite(data).all(), f"Nonfinite map: {path}")
        return data
    mask = values(directory / "mask.nii.gz") > 0
    require(mask.any(), f"Empty mask: {directory}")
    for number in numbers:
        for kind in ("cope", "varcope", "zstat"):
            data = values(directory / f"stats/{kind}{number}.nii.gz")[mask]
            if kind == "varcope":
                require((data >= 0).all() and (data > 0).any(), "Invalid contrast variance")


def check_l1(p, contrasts, reference):
    s = check_rendered(p["feat"] / "design.fsf", p, contrasts)
    x, c = matrix(p["feat"] / "design.mat"), matrix(p["feat"] / "design.con")
    bold = nib.load(str(p["bold"]))
    require(x.shape[0] == bold.shape[3] and x.shape[1] >= 14 and c.shape == (34, x.shape[1]), "Wrong design dimensions")
    require(np.isfinite(x).all() and np.isfinite(c).all(), "Nonfinite design")
    require(int(float(s["fmri(npts)"])) == bold.shape[3] and np.isclose(float(s["fmri(tr)"]), bold.header.get_zooms()[3]), "Wrong FEAT volume count/TR")
    con_text = (p["feat"] / "design.con").read_text()
    names = dict(re.findall(r"^/ContrastName(\d+)\s+(.+)$", con_text, re.M))
    projection = np.linalg.pinv(x) @ x
    primary = []
    neutral_zeroed = []
    for number, name, vector in contrasts:
        require(names.get(str(number), "").strip().strip('"') == name, f"design.con name mismatch COPE{number}")
        intended = np.pad(vector, (0, x.shape[1]-14))
        # feat_model zeroes a contrast whose modeled time course is empty.
        # Permit this only for pure neutral contrasts with explicitly empty EVs;
        # never waive altered outcome/decision or mixed neutral contrast weights.
        support = np.flatnonzero(vector)
        empty_neutral = (len(support) > 0 and set(support) <= {6, 7, 8}
                         and all(s[f"fmri(shape{i+1})"] == "10" for i in support)
                         and np.all(x[:, support] == 0) and np.all(c[number-1] == 0))
        require(np.allclose(c[number-1], intended, atol=1e-6, rtol=0) or empty_neutral,
                f"Actual matrix differs: COPE{number}; expected={intended.tolist()}; actual={c[number-1].tolist()}")
        if empty_neutral:
            neutral_zeroed.append(number)
        if not vector[6:9].any():
            require(np.max(np.abs(intended - intended @ projection)) < 1e-5, f"Non-neutral contrast not estimable: {name}")
            primary.append(number)
    check_maps(p["feat"], primary, reference)
    if neutral_zeroed:
        print(f"ACCEPTED FSL empty-neutral zeroing: {p['feat']} COPEs {neutral_zeroed}", flush=True)
    return neutral_zeroed


def check_l2(directory, parents, contrasts, reference):
    s = settings(directory / "design.fsf")
    for key, value in (("level", 2), ("mixed_yn", 3), ("npts", 2), ("ncopeinputs", 34)):
        require(float(s[f"fmri({key})"]) == value, f"Wrong L2 {key}")
    require([Path(s[f"feat_files({i})"]).resolve() for i in (1, 2)] == [p.resolve() for p in parents], "Wrong L2 parents/order")
    for number, _, vector in contrasts:
        if vector[6:9].any():
            continue
        require(s[f"fmri(copeinput.{number})"] == "1", f"COPE{number} omitted from L2")
        child = directory / f"cope{number}.feat"
        x, c = matrix(child / "design.mat"), matrix(child / "design.con")
        require(x.shape == (2, 1) and np.allclose(x, 1) and c.shape == (1, 1) and np.allclose(c, 1), "Wrong fixed-effects design")
        check_maps(child, [1], reference)


def write_tsv(path, header, rows):
    with path.open("w", newline="") as h:
        writer = csv.writer(h, delimiter="\t", lineterminator="\n")
        writer.writerow(header); writer.writerows(rows)


def fingerprint(path, image=False):
    stat = path.stat()
    result = dict(path=str(path.resolve()), size=stat.st_size, mtime_ns=stat.st_mtime_ns)
    if not image:
        result["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
    return result


def validate_pilot_resume(record, keys):
    """Resume this failed pre-L2 gate only; no generic reuse of arbitrary outputs."""
    require(record.resolve().is_relative_to((ROOT / "logs/records").resolve()),
            "Resume record must be inside this repository's logs/records")
    require(not (record / "pilot-passed.json").exists(), "Pilot already passed; this is not a pre-L2 resume")
    require(read_manifest(record / "L1-all.tsv") == keys, "Resume manifest changed")
    prior = json.loads((record / "provenance.json").read_text())
    require(prior.get("model") == "RF1-phase-resolved-14EV-34cope", "Wrong resume model")
    previous_sources = {s["path"]: s for s in prior["sources"]}
    required = [TEMPLATE, ROOT / "templates/CONTRAST_CROSSWALK.tsv",
                ROOT / "code/L1stats.sh", ROOT / "code/L2stats.sh"]
    require(all(str(p.resolve()) in previous_sources for p in required), "Incomplete resume provenance")
    for source in previous_sources.values():
        path = Path(source["path"])
        if path.resolve() == Path(__file__).resolve():
            continue  # This explicit resume permits the audit/coordinator fix only.
        require(fingerprint(path, "sha256" not in source) == source,
                f"Resume source changed: {path}; stop for review")
    pilot = read_manifest(record / "L1-pilot.tsv")
    require(set(pilot) <= set(keys), "Resume pilot is outside selected manifest")
    return pilot, prior["repo_commit"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--jobs", type=int, default=50)
    parser.add_argument("--l2-jobs", type=int, default=5)
    parser.add_argument("--confirm-idle", action="store_true")
    parser.add_argument("--resume-pilot-from", type=Path,
                        help="Prior records directory stopped at L1 audit; verify/reuse its pilot, never overwrite")
    args = parser.parse_args()
    require(args.confirm_idle, "Confirm no other RF1 model/input writers with --confirm-idle")
    require(1 <= args.jobs <= 50 and 1 <= args.l2_jobs <= 10, "Unsafe concurrency")
    env = os.environ.copy()
    upstream = Path(env.get("RF1_SRA_UPSTREAM_ROOT", "/ZPOOL/data/projects/rf1-sra-linux2"))
    env.update(FSL_DERIVATIVES_ROOT=str(ROOT / "derivatives/fsl"), TARGET_FWHM_MM="6",
               FSLSUB_PARALLEL="1", OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", MKL_NUM_THREADS="1", NUMEXPR_NUM_THREADS="1")
    env.setdefault("BIDS_ROOT", str(upstream / "bids"))
    env.setdefault("CONFOUNDS_ROOT", str(upstream / "derivatives/fsl/confounds_tedana"))
    env.setdefault("HARMONIZED_ROOT", str(ROOT / "derivatives/harmonized"))
    for tool in ("feat", "fslnvols", "fslval"):
        require(shutil.which(tool, path=env["PATH"]), f"Missing FSL tool: {tool}")
    require((Path(env.get("FSLDIR", "/missing")) / "etc/flirtsch/ident.mat").is_file(), "Missing FSLDIR identity matrix")
    keys = read_manifest(args.manifest)
    _, contrasts = contract()
    reference = nib.load(str(ROOT / "resources/rf1_MNI152NLin6Asym_reference_grid.nii.gz"))
    units = {key: paths(key, env) for key in keys}
    resume_pilot, pilot_commit = ([], None)
    if args.resume_pilot_from:
        resume_pilot, pilot_commit = validate_pilot_resume(args.resume_pilot_from, keys)
    groups = defaultdict(list)
    sources = [fingerprint(args.manifest), fingerprint(TEMPLATE)]
    for relative in ("templates/CONTRAST_CROSSWALK.tsv", "templates/L2_task-sharedreward_model-1_type-act.fsf",
                     "resources/rf1_MNI152NLin6Asym_reference_grid.nii.gz",
                     "code/phase_resolved_activation.py", "code/project_config.sh", "code/BIDSto3col.sh",
                     "code/gen3colfiles.sh", "code/run_gen3colfiles.sh", "code/L1stats.sh",
                     "code/run_L1stats.sh", "code/L2stats.sh", "code/run_L2stats.sh"):
        sources.append(fingerprint(ROOT / relative))
    neutral_pairs = set()
    for key, p in units.items():
        for name in ("feat", "l2", "ev", "rendered"):
            require(p[name].resolve().is_relative_to(ROOT.resolve() / "derivatives/fsl"),
                    f"Output redirected outside RF1 derivatives/fsl: {p[name]}")
        require((p["feat"].is_dir() if key in resume_pilot else not p["feat"].exists()) and not p["l2"].exists(),
                f"Existing model at {p['feat']} or {p['l2']}; stop for a scoped audit/resume, never overwrite")
        expected = event_rows(p["events"])
        bold = nib.load(str(p["bold"]))
        require(len(bold.shape) == 4 and bold.shape[:3] == reference.shape[:3]
                and np.allclose(bold.affine, reference.affine, atol=1e-4, rtol=0), f"Wrong BOLD grid: {p['bold']}")
        require(np.isfinite(bold.header.get_zooms()[3]) and bold.header.get_zooms()[3] > 0, "Invalid BOLD TR")
        conf = np.loadtxt(p["confounds"], ndmin=2)
        require(conf.shape[0] == bold.shape[3] and np.isfinite(conf).all(), f"Invalid confounds: {key}")
        for label in LABELS:
            require(all(onset + duration <= bold.shape[3]*bold.header.get_zooms()[3] + .01
                        for onset, duration, _ in expected[label]), f"Event exceeds acquisition: {key} {label}")
        groups[key[:2]].append(key)
        if any(not expected[LABELS[i]] for i in (6, 7, 8)):
            neutral_pairs.add(key[:2])
        sources.extend([fingerprint(p["events"]), fingerprint(p["confounds"]), fingerprint(p["bold"], True)])
    pairs = [key for key in groups if len(groups[key]) == 2]
    require(pairs, "Need at least one two-run subject for L1/L2 pilot")
    # Include a neutral-empty case when available, then another two-run subject.
    pairs.sort(key=lambda k: (k not in neutral_pairs, k))
    pilot_subjects = pairs[:2]
    pilot = sorted(key for subject in pilot_subjects for key in groups[subject])
    if args.resume_pilot_from:
        require(pilot == resume_pilot, "Selected pilot differs from prior run")
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    report = ROOT / f"logs/records/phase-resolved-{stamp}"
    report.mkdir(parents=True, exist_ok=False)
    logs = ROOT / f"logs/phase-resolved-{stamp}"
    sha = subprocess.check_output(["git", "-C", str(ROOT), "rev-parse", "HEAD"], text=True).strip()
    (report / "provenance.json").write_text(json.dumps(dict(model="RF1-phase-resolved-14EV-34cope",
        repo_commit=sha, resume_from=str(args.resume_pilot_from) if args.resume_pilot_from else None,
        pilot_source_commit=pilot_commit, sources=sources, contrast_map=[dict(cope=i, name=n, vector=v.tolist(),
        nonneutral=not v[6:9].any()) for i,n,v in contrasts]), indent=2)+"\n")
    for name, rows in (("L1-all", keys), ("L1-pilot", pilot)):
        write_tsv(report / f"{name}.tsv", ["subject", "session", "run"], rows)
    write_tsv(report / "L2-all.tsv", ["subject", "session"], sorted(pairs))
    write_tsv(report / "L2-pilot.tsv", ["subject", "session"], pilot_subjects)

    def run(script, *arguments):
        cmd = ["bash", str(ROOT / "code" / script), *map(str, arguments)]
        print("COMMAND:", " ".join(cmd), flush=True)
        try:
            subprocess.run(cmd, env=env, cwd=ROOT, check=True)
        except subprocess.CalledProcessError:
            if logs.exists():
                for f in sorted(logs.rglob("*.log")):
                    text = f.read_text(errors="replace")
                    if "ERROR" in text or "child process" in text:
                        print(f"FAILED LOG {f}:\n" + "\n".join(text.splitlines()[-35:]), flush=True)
            raise

    def unchanged():
        for source in sources:
            require(fingerprint(Path(source["path"]), "sha256" not in source) == source,
                    f"Input changed during run: {source['path']}")

    print(f"Preflight passed: {len(keys)} runs, {len(groups)} subjects; pilot {pilot_subjects}; activation only", flush=True)
    if not args.resume_pilot_from:
        run("run_gen3colfiles.sh", "--manifest", report / "L1-all.tsv", "--jobs", 8, "--overwrite")
        run("run_L1stats.sh", "--manifest", report / "L1-all.tsv", "--jobs", 8, "--render-only", "--log-dir", logs / "render")
    for p in units.values():
        check_rendered(p["rendered"], p, contrasts)
    unchanged()
    if not args.resume_pilot_from:
        run("run_L1stats.sh", "--manifest", report / "L1-pilot.tsv", "--jobs", 2, "--log-dir", logs / "L1-pilot")
    else:
        print("RESUME: auditing completed pilot L1; no EV regeneration or pilot refit.", flush=True)
    for key in pilot:
        check_l1(units[key], contrasts, reference)
    run("run_L2stats.sh", "--manifest", report / "L2-pilot.tsv", "--type", "act", "--jobs", 1, "--log-dir", logs / "L2-pilot")
    for subject in pilot_subjects:
        parents = [units[k]["feat"] for k in groups[subject]]
        check_l2(units[groups[subject][0]]["l2"], parents, contrasts, reference)
    (report / "pilot-passed.json").write_text(json.dumps(dict(subjects=pilot_subjects, runs=len(pilot), passed=True))+"\n")
    print("CHECK PASSED: pilot L1 timing/design/maps and L2 fixed-effects parents. Launching remaining RF1 activation.", flush=True)
    unchanged()
    run("run_L1stats.sh", "--manifest", report / "L1-all.tsv", "--jobs", args.jobs, "--log-dir", logs / "L1-full")
    for key, p in units.items():
        check_l1(p, contrasts, reference)
        print("VERIFIED L1:", key, flush=True)
    unchanged()
    run("run_L2stats.sh", "--manifest", report / "L2-all.tsv", "--type", "act", "--jobs", args.l2_jobs, "--log-dir", logs / "L2-full")
    subject_rows = []
    for subject, runs in sorted(groups.items()):
        if len(runs) == 2:
            output = units[runs[0]]["l2"]
            check_l2(output, [units[k]["feat"] for k in runs], contrasts, reference)
            strategy = "fixed_effects"
        else:
            output = units[runs[0]]["feat"]
            strategy = "l1_passthrough"
        subject_rows.append((*subject, ",".join(k[2] for k in runs), strategy, str(output), sha))
    unchanged()
    write_tsv(report / "verified-subject-outputs.tsv",
              ["subject", "session", "runs", "strategy", "output", "source_repo_commit"], subject_rows)
    summary = dict(runs=len(keys), subjects=len(groups), fixed_effects=len(pairs),
                   passthrough=len(groups)-len(pairs), pilot_subjects=len(pilot_subjects),
                   verified=True, type="activation", source_repo_commit=sha)
    (report / "summary.json").write_text(json.dumps(summary, indent=2)+"\n")
    note = ("# RF1 phase-resolved production audit\n\n```json\n" + json.dumps(summary, indent=2) +
            f"\n```\n\nEvidence: `{report.relative_to(ROOT)}`. All 34 contrast names/vectors checked; "
            "neutral-weighted maps excluded from estimability/map-quality gate. Canonical phase EV timing, "
            "grid, finite maps, positive variances, and fixed-effects parents checked. "
            "No final imaging QC or PPI approval implied. No full-trial outputs changed by this workflow.\n")
    (report / "audit.md").write_text(note)
    (ROOT / "logs/records/phase-resolved-production-audit.md").write_text(note)
    print("CHECK PASSED: RF1 phase-resolved activation and subject outputs verified.", flush=True)
    print("Reports:", report, flush=True)


if __name__ == "__main__":
    main()
