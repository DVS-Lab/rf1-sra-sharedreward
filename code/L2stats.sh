#!/usr/bin/env bash
set -euo pipefail
# Prevent local fsl_sub from expanding one FEAT unit into a machine-sized pool.
export FSLSUB_PARALLEL="${FSLSUB_PARALLEL:-1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)";source "$SCRIPT_DIR/project_config.sh"
usage(){ echo "Usage: L2stats.sh SUBJECT act [--session 01] [--dry-run|--render-only] [--overwrite]" >&2; }
(( $#>=2 ))||{ usage;exit 2;};sub="$(normalize_subject "$1")";type="$2";shift 2;[[ "$type" == act ]]||{ echo 'ERROR: only validated activation L2 is enabled' >&2;exit 2;};session=01;mode=run;overwrite=0
while(( $# ));do case "$1" in --session)session="$2";shift 2;;--dry-run)mode=dry-run;shift;;--render-only)mode=render-only;shift;;--overwrite)overwrite=1;shift;;-h|--help)usage;exit 0;;*)echo "ERROR: unknown argument: $1" >&2;exit 2;;esac;done
session="$(normalize_session "$session")";require_target_fwhm;ncopes=34;input1="$(l1_output_base "$sub" "$session" 1 act).feat";input2="$(l1_output_base "$sub" "$session" 2 act).feat"
for input in "$input1" "$input2";do [[ -f "$input/cluster_mask_zstat1.nii.gz" && -f "$input/stats/cope34.nii.gz" ]]||{ echo "ERROR: complete L1 input required: $input" >&2;exit 1;};done
output="$(l2_output_base "$sub" "$session" act)";template="$PROJECT_ROOT/templates/L2_task-sharedreward_model-1_type-act.fsf";outdir="$FSL_DERIVATIVES_ROOT/sub-$sub/ses-$session";rendered="$outdir/L2_sub-${sub}_task-sharedreward_ses-${session}_model-1_type-act.fsf"
printf 'L2 plan (fixed effects across runs 1 + 2)\n  run 1: %s\n  run 2: %s\n  output: %s.gfeat\n  FSLSUB_PARALLEL: %s\n' "$input1" "$input2" "$output" "$FSLSUB_PARALLEL";[[ "$mode" == dry-run ]]&&exit 0
gfeat="${output}.gfeat"
if [[ -e "$gfeat" ]]; then
  if (( ! overwrite )); then [[ -f "$gfeat/cope34.feat/cluster_mask_zstat1.nii.gz" ]] && { echo "Complete output exists; skipping: $gfeat"; exit 0; }; echo "ERROR: incomplete output exists; use --overwrite: $gfeat" >&2; exit 1; fi
  case "$gfeat" in "$FSL_DERIVATIVES_ROOT"/*) rm -rf -- "$gfeat" ;; *) echo 'ERROR: refusing removal outside derivative root' >&2; exit 1 ;; esac
fi
mkdir -p "$outdir";esc(){ printf '%s' "$1"|sed 's/[&@\\]/\\&/g';};sed -e "s@OUTPUT@$(esc "$output")@g" -e "s@INPUT1@$(esc "$input1")@g" -e "s@INPUT2@$(esc "$input2")@g" "$template">"$rendered";grep -En 'OUTPUT|INPUT1|INPUT2' "$rendered">/dev/null&&{ echo 'ERROR: unresolved placeholder' >&2;exit 1;}||true;echo "Rendered: $rendered";[[ "$mode" == render-only ]]&&exit 0
command -v feat>/dev/null||{ echo 'ERROR: feat unavailable' >&2;exit 1;};feat "$rendered";for cope in $(seq "$ncopes");do d="$gfeat/cope${cope}.feat";rm -f -- "$d/stats/res4d.nii.gz" "$d/stats/corrections.nii.gz" "$d/stats/threshac1.nii.gz" "$d/filtered_func_data.nii.gz" "$d/var_filtered_func_data.nii.gz";done
