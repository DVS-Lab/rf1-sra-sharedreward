# Code

## Active workflow

| Stage | Entry point | Output |
|---|---|---|
| L1 readiness | `build_L1_manifest.py` | ready/missing TSVs from canonical Linux2 inputs |
| Event conversion | `run_gen3colfiles.sh` → `gen3colfiles.sh` → `BIDSto3col.sh` | session/run-aware EV files |
| RF1 grid audit | `audit_rf1_grid.py` | tolerance-based spatial-grid inventory plus qform/sform metadata QC |
| Reference resource | `create_reference_grid.py` | zero-valued grid NIfTI + JSON |
| Smoothness | `measure_smoothness.sh` | classic and ACF estimates |
| Candidate targets | `propose_smoothing_targets.py` | feasibility/distribution TSV |
| Target smoothing | `smooth_to_target.sh` | target-encoded BOLD + achieved-smoothness QC |
| tSNR | `compute_tsnr.py` | voxel map and JSON summary; optional fixed-reference-mask intersection and coverage |
| L1 activation | `run_L1stats.sh` → `L1stats.sh` | 14-EV/34-contrast FEAT directories |
| L2 fixed effects | `build_L2_manifest.py`, `run_L2stats.sh` → `L2stats.sh` | two-run fixed-effects GFEAT directories |
| Run records | `run_logged.sh` | local raw log + tracked compact record |

All active paths and naming functions live in `project_config.sh`. Linux2 is the sole RF1 upstream. `TARGET_FWHM_MM` defaults to the approved 6-mm total classic-FWHM target and is encoded in smoothed BOLD and L1/L2 names.

## Example Phase 0 commands on Linux2

```bash
cd /ZPOOL/data/projects/rf1-sra-sharedreward
git pull --ff-only origin main

python3 code/build_L1_manifest.py \
  --sessions 01 \
  --output logs/runlists/L1-ready.tsv \
  --missing-output logs/runlists/L1-missing.tsv

python3 code/audit_rf1_grid.py \
  --fmriprep-root /ZPOOL/data/projects/rf1-sra-linux2/derivatives/fmriprep \
  --output-prefix logs/records/rf1-sharedreward-grid-audit
```

Only if the grid audit exits 0 and its modal source is reviewed:

```bash
python3 code/create_reference_grid.py \
  --source /path/to/reviewed/modal/sharedreward_bold.nii.gz \
  --output resources/rf1_MNI152NLin6Asym_reference_grid.nii.gz \
  --json-output resources/rf1_MNI152NLin6Asym_reference_grid.json
```

Run major smoothing and FEAT steps through `run_logged.sh` and place compact summary tables under `logs/records/`. Phase 0 approved `TARGET_FWHM_MM=6` on 2026-08-23; achieved-smoothness QC remains mandatory before FEAT.

## Scientific constraints

- canonical BIDS timing is copied exactly into three-column files;
- `missed_decision` and `missed_outcome` are distinct optional nuisance EVs;
- FEAT smoothing is 0;
- `C_neu` retains the inherited per-EV temporal-filter flag pending an explicit decision;
- L2 is fixed effects and requires complete runs 1 and 2;
- connectivity templates are not yet revalidated;
- L3 is not standardized in this pass.

Historical behavioral, ROI, PPI/nPPI, and L3 scripts remain in Git history or clearly non-active locations. See `WORKFLOW_AUDIT.md` before reusing them.
