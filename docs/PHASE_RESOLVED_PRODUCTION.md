# RF1 phase-resolved activation production

## Decision and scope — 2026-10-05

The tracked Linux2 production inventory and PI clarification establish that
canonical phase-resolved RF1 L1/L2 has not yet run. Prior successful pooled
full-trial runs are a different model, not existing canonical RF1 outputs.
Proceed with a new activation run here. No source imaging, smoothing, upstream
events, full-trial outputs, or scientific contrast vectors are changed.

The initial explicit run selection is the RF1 subset of the successful pooled
run's frozen task-ready inventory:

`sharedreward-aging/logs/records/full-analysis-20260930-203949-441196/L1-task-ready.tsv`

That selection contains 655 RF1 runs / 346 subject-sessions: 309 with both
runs and 37 with one run. It preserves the reviewed source/task eligibility;
it is not the ratings cohort and does not introduce final imaging QC exclusions.
The reusable coordinator accepts a plain `subject`, `session`, `run` manifest;
it contains no aging-specific cohort-selection logic. Future additional runs
must be reviewed explicitly, not silently discovered during this launch.

## Preserved model

- Canonical upstream phase-resolved BIDS timings, not harmonized full-trial timings.
- Existing 14 EV / 34 contrast activation template and ordering.
- Genuine empty neutral and miss EVs use shape 10. Present task/miss EVs use
  shape 3 and double-gamma convolution. No fabricated trials.
- Every per-EV temporal filter remains off. The existing high-pass setting,
  prewhitening, and zero additional FEAT smoothing remain unchanged.
- Contrast identity checks cover all 34 actual FSF/design.con vectors and names.
  Neutral-weighted COPEs 7–9 and 20–22 are retained but do not drive
  estimability/map-quality acceptance. No neutral inference is approved.
- Existing 6-mm total-target BOLD and canonical nuisance matrices are reused.
- Two retained runs use fixed effects (`mixed_yn=3`); one-run subject outputs
  are explicitly identified as L1 passthroughs, never mislabeled as fitted L2.
- This launch is activation only. Phase-resolved PPI needs its own validation;
  the already-completed pooled full-trial PPI is untouched.

## Execution and gates

Use `code/run_logged.sh --include-full-log` around:

```bash
"$IMAGING_PYTHON" code/phase_resolved_activation.py \
  --manifest logs/records/phase-resolved-launch/L1-ready.tsv \
  --jobs 50 --l2-jobs 5 --confirm-idle
```

Run detached on Linux2 with `nohup setsid -f -w`, stdin from `/dev/null`, and
an outer log under `logs/`. `--confirm-idle` acknowledges that no other process
is writing these inputs or RF1 model paths. Do not pull code during a run.

The coordinator checks every input, regenerates only RF1 EV derivatives,
renders/audits all FSFs, then runs up to two two-run pilot subjects (including
an empty-neutral example if available). Actual pilot L1 designs/maps and L2
parents/fixed-effects settings must pass before the full batch starts.
L1 permits up to 50 activation workers, not 50 activation/PPI pairs. L2 permits
5 fixed-effects workers; nested FSL submission and numerical threads are
limited to one. A worker count can be below the cap between stages or while
the existing FIFO batch launcher waits for a longer unit.

After all L1 finishes, the coordinator checks canonical EV timings, TR/volume
counts, exact contrast coefficients/names, non-neutral estimability, affine,
finite COPE/VARCOPE/Z maps, and nonnegative/nonzero in-mask contrast variances.
It then runs and verifies paired-run L2 and records one-run passthroughs.
These are technical validity checks, not Cooper's final QC/cohort decisions.

Existing FEAT/GFEAT directories cause an initial refusal, not deletion or
silent reuse. If execution stops after producing partial outputs, preserve
them and review the logs before constructing a scoped resume. Do not add
`--overwrite` or delete the full tree to bypass that check.

## Outputs and evidence

Within `derivatives/fsl/sub-S/ses-01/`:

```text
L1_task-sharedreward_ses-01_model-1_type-act_run-R_smTo-6.feat
L2_task-sharedreward_ses-01_model-1_type-act_smTo-6.gfeat
```

Each launch writes a unique `logs/records/phase-resolved-UTCSTAMP/` with:

- frozen L1/L2 and pilot manifests;
- repo commit, source event/confound hashes, template/code/reference hashes,
  and BOLD path/size/mtime fingerprints (not whole-BOLD content hashes);
- all 34 contrast names, indices, vectors, and neutral classification;
- pilot pass record; on full success, summary and verified subject-output table.

`logs/records/phase-resolved-production-audit.md` is written only on full
success. Commit the run record and this evidence directory after completion.
Raw/per-worker logs and imaging outputs are not a substitute for that audit.
Local regression tests exercise actual EV generation/rendering, absent/present
neutral/miss handling, unchanged 34-vector signature, timing mismatch rejection,
synthetic actual-design/map checks, fixed effects, and malformed manifests.
Real FEAT validation occurs on Linux2 at the pilot gate, not on the Mac.

This workflow writes only RF1 analysis derivatives and logs. It does not
launch SRNDNA phase reconstruction/modeling, build a new pooled L3 family, or
promote either estimand to manuscript primary. Those remain separate next steps.
