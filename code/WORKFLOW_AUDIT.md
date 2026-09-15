# Shared Reward workflow audit

Historical audit date: 2026-08-22. Status reconciled 2026-09-15. Repositories
originally inspected: `rf1-sra-sharedreward`, `sharedreward-aging`, `r01-soi`,
`multiecho-pilot`, and `rf1-sra-linux2` documentation/code.

## Current boundary

RF1-only activation remains **14 EVs / 34 contrasts**, phase-resolved. Pooled
RF1+ds003745 analyses fit both datasets separately inside `sharedreward-aging`
under its **full-trial 28-contrast activation / 29-contrast PPI** contract. The
two scientific models are intentional, not drift. Shared reference-grid and
smoothed-BOLD resources do not make their FEAT COPE maps interchangeable.
See the [pooled current-status index](https://github.com/DVS-Lab/sharedreward-aging/blob/main/docs/CURRENT_STATUS.md)
for cohort arithmetic, verified Linux2 execution and outstanding decisions.

## Scientific model comparison

| Setting | Historical RF1 | `r01-soi` | Historical aging | Authoritative RF1 |
|---|---:|---:|---:|---:|
| Original EVs | 13 | 13 | 13 | 14 |
| Contrasts | 34 | 34 | 32 | 34 |
| HRF | double gamma | double gamma | double gamma | double gamma |
| Nominal FEAT smoothing | 6 mm | 6 mm in inspected template | 5 mm | 0 mm |
| TR | 1.615 hard-coded | 1.615 hard-coded | placeholder | image/header |
| Prewhitening | on | on | on | on |
| High-pass filtering | disabled globally | disabled globally | disabled globally | disabled globally |
| Registration | disabled for standard-space input | same | same | disabled for standard-space input |
| Miss model | one optional generic EV | one optional generic EV | one generic EV, unconvolved | two optional convolved nuisance EVs |

The historical RF1 and `r01-soi` activation templates inspected on August 22
were scientifically identical apart from placeholder handling; both contained
34 contrasts and nominal 6-mm smoothing. This is not a claim that the modernized
14-EV, zero-FEAT-smoothing RF1 template remains identical to `r01-soi`. The old
assertion that the inspected `r01-soi` file used 5 mm was not supported by that
file; Git history may contain another version.

The historical aging template is not a safe scientific source. Besides omitting the two decision contrasts that occupy RF1 copes 33–34, it contains malformed vectors for neutral and several decision/neutral comparisons: weights appear in the first column while the named condition columns are zero. Its generic miss EV also has `convolve10 = 0`, unlike ordinary task regressors. It is retained as historical provenance, not promoted.

### Resolved temporal-filter anomaly

Historical RF1 and `r01-soi` applied temporal filtering only to `C_neu`
(`tempfilt_yn7 = 1`) while neighboring task EVs used 0. The active RF1
templates now set every task EV, including `C_neu`, to 0. This implements the
2026-09-04 decision to remove the isolated inherited setting and is protected
by the template contract test. Archived templates remain unchanged as
historical provenance.

### Approved modernization

The authoritative activation order is:

1. `event_computer_punish`
2. `event_computer_reward`
3. `event_friend_punish`
4. `event_friend_reward`
5. `event_stranger_punish`
6. `event_stranger_reward`
7. `event_computer_neutral`
8. `event_friend_neutral`
9. `event_stranger_neutral`
10. `missed_decision`
11. `missed_outcome`
12. `friend_face`
13. `stranger_face`
14. `computer_non-face`

All 34 established substantive contrast vectors are retained, with zeros inserted for both miss nuisance EVs. Decision columns shift by one, but cope numbers do not. See `templates/CONTRAST_CROSSWALK.tsv`.

FEAT smoothing is now zero. AFNI target smoothing is a separate measured derivative, requires an explicitly approved `TARGET_FWHM_MM`, and must record achieved smoothness.

## File classification

| Material | Classification | Disposition |
|---|---|---|
| canonical Linux2 `_events.tsv`, fMRIPrep BOLD, TEDANA confounds | CURRENT RF1 IMPLEMENTATION | sole production inputs |
| new model-1 activation template and EV/L1/L2 scripts | CURRENT SCIENTIFIC MODEL | authoritative RF1-only model; Phase 0 target approved |
| `L1_task-*_type-ppi.fsf`, VS masks | PPI/NPPI | provenance retained; scientific revalidation follows activation |
| network templates and PNAS masks | PPI/NPPI | historical capability; do not imply validated production support |
| FLOBS templates in aging | FLOBS/HISTORICAL MODEL | sensitivity/provenance only |
| `L3stats.sh`, L3 templates and FEAT design artifacts | SINGLE-TRIAL/MANUSCRIPT-SPECIFIC or UNCERTAIN | not standardized; group modeling deferred |
| MATLAB/R behavioral analyses and derived figures/tables | BEHAVIORAL | preserved in Git history; not part of active imaging workflow |
| old fMRIPrep/TEDANA/HPC wrappers in aging | PREPROCESSING (historical) | superseded by pinned modern wrapper |
| `multiecho-pilot` blur/smoothness prototypes | QC/HARMONIZATION | concepts adapted; unsafe shared AFNI work files not copied |
| `.DS_Store`, `.goutputstream-*`, editor backups, `.feat` GUI artifacts | TEMPORARY/JUNK | remove/ignore |

## Boundaries

`rf1-sra-sharedreward` does not regenerate BIDS, run fMRIPrep, or own aging/ds003745 models. `sharedreward-aging` owns the model-specific cross-dataset full-trial representation, ds003745 preprocessing, RF1-grid resampling, and pooled QC. `r01-soi` should consume authoritative cope meanings via the crosswalk rather than retain a fourth implementation.

## Completed decisions and remaining scope

- The signal-free RF1 modal-grid resource, full initial cross-dataset
  characterization and complete 100-run modern ds003745 preprocessing are done.
- The **6-mm total classic-FWHM** target was approved on August 23. FEAT
  smoothing is zero; ds003745 uses `wsinc5` BOLD / nearest-neighbor mask grid
  resampling in its owning repository. Later catch-up does not reopen that choice.
- The isolated `C_neu` per-EV temporal-filter flag was normalized to 0 in the active templates on 2026-09-04.
- This repository's RF1-only seed/network PPI templates and seed provenance still
  require scientific revalidation; success of the separate pooled sub-144 PPI
  pilot does not certify this model. L3 is not standardized here.
- Current upstream historical-review items affecting Shared Reward (10657,
  10668, 11923) require scoped scientific/identity adjudication before final
  cohort freeze. They do not justify inventing new exclusions from technical QC.
