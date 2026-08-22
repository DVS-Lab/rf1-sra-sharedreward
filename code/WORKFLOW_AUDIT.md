# Shared Reward workflow audit

Audit date: 2026-08-22. Repositories inspected: `rf1-sra-sharedreward`, `sharedreward-aging`, `r01-soi`, `multiecho-pilot`, and current `rf1-sra-linux2` documentation/code.

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

The inspected current RF1 and `r01-soi` activation templates are scientifically identical apart from placeholder handling. Both contain 34 contrasts. The assertion that the inspected `r01-soi` template used 5 mm was not supported by its current file: it also contains `fmri(smooth) 6`. Git history may contain another version.

The historical aging template is not a safe scientific source. Besides omitting the two decision contrasts that occupy RF1 copes 33–34, it contains malformed vectors for neutral and several decision/neutral comparisons: weights appear in the first column while the named condition columns are zero. Its generic miss EV also has `convolve10 = 0`, unlike ordinary task regressors. It is retained as historical provenance, not promoted.

### Retained anomaly

Historical RF1 and `r01-soi` apply temporal filtering to `C_neu` (`tempfilt_yn7 = 1`) while neighboring task EVs use 0. Global temporal high-pass filtering is disabled (`temphp_yn = 0`), so the practical effect needs confirmation from rendered FEAT designs. Because intent is unknown, the authoritative template retains this setting and the contract test identifies it explicitly. David should decide whether a later model version normalizes it.

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
| new model-1 activation template and EV/L1/L2 scripts | CURRENT SCIENTIFIC MODEL | authoritative after Phase 0 target approval |
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

## Phase 0 unresolved items

- Generate the zero-valued grid resource on Linux2 from the verified modal Shared Reward grid.
- Run full RF1 baseline smoothness/tSNR characterization and a small modern ds003745 pilot.
- Review candidate smoothing targets; none is currently selected.
- Decide whether to retain or normalize the `C_neu` per-EV temporal-filter flag in a future explicit model version.
- Revalidate seed/network PPI provenance and templates after activation is stable.
