# RF1 Shared Reward

This repository is the authoritative downstream RF1 Shared Reward workflow. It consumes canonical data produced by [`rf1-sra-linux2`](https://github.com/DVS-Lab/rf1-sra-linux2) and owns Shared Reward event conversion, spatial harmonization, first-level FEAT models, within-subject fixed-effects models, and analysis QC.

```text
rf1-sra-linux2
  canonical BIDS events
  fMRIPrep MNI152NLin6Asym BOLD
  TEDANA-enhanced confounds
            |
            v
rf1-sra-sharedreward
  BIDS events -> three-column EVs
  RF1 reference grid
  measured AFNI target smoothing
            |
            v
  L1 activation / supported connectivity
            |
            v
  L2 fixed effects across runs 1 + 2
```

Spatial smoothing is performed outside FEAT with AFNI `3dBlurToFWHM` to an explicitly approved, measured target FWHM. FEAT spatial smoothing is disabled. `TARGET_FWHM_MM` is deliberately unset until Phase 0 harmonization review is complete; production smoothing and L1 therefore fail instead of guessing a 5- or 6-mm target.

The reusable RF1 workflow does not contain ds003745 or pooled-aging logic. Those analyses live in [`sharedreward-aging`](https://github.com/DVS-Lab/sharedreward-aging), which references RF1 outputs rather than copying them.

## Inputs

Default Temple paths are configurable through environment variables:

```bash
export RF1_SRA_UPSTREAM_ROOT=/ZPOOL/data/projects/rf1-sra-linux2
export BIDS_ROOT="$RF1_SRA_UPSTREAM_ROOT/bids"
export FMRIPREP_ROOT="$RF1_SRA_UPSTREAM_ROOT/derivatives/fmriprep"
export CONFOUNDS_ROOT="$RF1_SRA_UPSTREAM_ROOT/derivatives/fsl/confounds_tedana"
export FSL_DERIVATIVES_ROOT="$PWD/derivatives/fsl"
```

The canonical RF1 event model retains separate decision and outcome phases. The authoritative activation design has 14 EVs: nine outcome conditions, `missed_decision`, `missed_outcome`, and three partner decision conditions. Miss EVs are optional nuisance regressors and receive zero weight in every substantive contrast.

## Phase 0 hard gate

The repository currently supports characterization and pilot work. Before any production L1 launch:

1. create and verify the zero-valued RF1 reference-grid resource from the modal Linux2 Shared Reward grid;
2. measure baseline smoothness in both datasets;
3. evaluate candidate targets and pilot achieved-versus-requested smoothing;
4. review tSNR, motion, coverage, and outliers;
5. explicitly approve and export `TARGET_FWHM_MM`.

Do not select a production target from the historical FEAT kernel values.

## Validation and provenance

```bash
make test
```

Major Linux2 runs should use `code/run_logged.sh`. Raw logs remain local under `logs/runs/`; compact Markdown records and small QC tables under `logs/records/` are intended for Git.

See [code/README.md](code/README.md), [code/WORKFLOW_AUDIT.md](code/WORKFLOW_AUDIT.md), and [templates/README.md](templates/README.md) before production use.
