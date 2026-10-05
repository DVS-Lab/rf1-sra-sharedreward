# Empty-neutral contrast audit correction — 2026-10-05

The Linux2 run at model commit `3c9aec2` completed all four pilot L1 workers,
then stopped in `check_l1` with `Actual matrix differs: COPE9`. No pilot L2
or full L1 batch was launched. Source record:
`20261005-102746_RF1-phase-resolved-20261005-102746.md`.

COPE9 is `S_neu`. The previous audit required its original nonzero contrast
vector even when the corresponding EV was explicitly empty. Local FSL source
`src/fsl-feat5/feat_model.cc`, lines 1594–1602, zeroes contrast vectors whose
modeled time course has no variation. A real local `feat_model` execution with
the unchanged RF1 template, empty neutral EVs, and synthetic events reproduced
zero rows for COPEs 7–9 while retaining the mixed neutral contrast vectors.
This reproduces the audit's failure mechanism; the actual Linux2 matrices
remain on Linux2 and will be checked during resume.

The corrected audit permits an all-zero actual row only for a pure-neutral
contrast, when its EV uses shape 10 and corresponding actual design column
is exactly zero. FSF coefficients, names, and numbering remain exact checks.
Substantive contrasts and mixed neutral contrasts cannot use this exception.
All 34 contrast definitions remain unchanged. No scientific exclusion, model
output, timing, or smoothing change is made.

The prior 25 tests modeled design.con directly and missed FSL's runtime
zeroing. Added regression coverage includes the real `feat_model` behavior,
rejection of zeroed substantive/mixed contrasts, rejection of nonempty neutral
design columns, and resume source/manifest/stage checks. The real-FSL test
requires FSLDIR and feat_model; otherwise it is explicitly skipped.

A scoped pre-L2 resume preserves the four completed pilots, verifies original
inputs and worker/template fingerprints, records the prior model commit, and
re-audits before allowing L2/full production. No Linux2 restart or successful
production completion is claimed by this local correction record.
