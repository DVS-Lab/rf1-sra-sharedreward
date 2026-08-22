# FEAT templates

`L1_task-sharedreward_model-1_type-act.fsf` is the authoritative activation template. It has 14 EVs and 34 contrasts, uses the double-gamma HRF, prewhitening, no FEAT registration, and `fmri(smooth) = 0`. Inputs must already be on the RF1 grid and smoothed to the approved measured target.

The two optional miss nuisance EVs use shape 3 when their files exist and shape 10 otherwise. Both are convolved like task regressors and carry zero weight in substantive contrasts.

`CONTRAST_CROSSWALK.tsv` maps names and cope numbers across the historical RF1, `r01-soi`, and aging templates. The aging vectors marked as different must not be treated as equivalent solely because their names or cope numbers match.

PPI/nPPI templates remain provenance material until activation and their seed/network definitions are revalidated. L3 templates are historical and are not part of the standardized workflow.
