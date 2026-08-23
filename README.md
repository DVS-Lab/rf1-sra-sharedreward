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

Spatial smoothing is performed outside FEAT with AFNI `3dBlurToFWHM` to the approved 6-mm total classic-FWHM target. FEAT spatial smoothing is disabled. The target was selected on 2026-08-23 after complete RF1/ds003745 characterization; it is not an added 6-mm Gaussian kernel.

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

## Phase 0 smoothing decision

Phase 0 established the following production contract:

1. use the verified RF1 `MNI152NLin6Asym` reference grid;
2. use identity-grid `wsinc5` resampling for ds003745 continuous BOLD and nearest-neighbor resampling for masks;
3. target 6 mm total classic FWHM with `3dBlurToFWHM` inside each run's fMRIPrep whole-brain mask;
4. retain ACF estimates as diagnostics and estimate inferential ACF from model residuals when needed;
5. keep FEAT smoothing at zero to prevent double smoothing.

The measured classic-FWHM maximum was 4.619 mm across 765 analysis-ready runs, so every run can be blurred upward to 6 mm. See [docs/SMOOTHING_HARMONIZATION.md](docs/SMOOTHING_HARMONIZATION.md).

## Validation and provenance

```bash
make test
```

Major Linux2 runs should use `code/run_logged.sh`. Raw logs remain local under `logs/runs/`; compact Markdown records and small QC tables under `logs/records/` are intended for Git.

See [code/README.md](code/README.md), [code/WORKFLOW_AUDIT.md](code/WORKFLOW_AUDIT.md), and [templates/README.md](templates/README.md) before production use.
