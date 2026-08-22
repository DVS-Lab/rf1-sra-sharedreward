#!/usr/bin/env bash

# Render/run one authoritative RF1 Shared Reward activation model.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"; source "${SCRIPT_DIR}/project_config.sh"
usage(){ echo "Usage: L1stats.sh SUBJECT RUN 0 [--session 01] [--bold FILE] [--confounds FILE] [--dry-run|--render-only] [--overwrite]" >&2; }
(( $#>=3 ))||{ usage;exit 2; };sub="$(normalize_subject "$1")";run="$2";ppi="$3";shift 3
[[ "$ppi" == 0 || "$ppi" == act ]]||{ echo 'ERROR: Phase-0 authoritative worker currently validates activation only; PPI revalidation follows activation.' >&2;exit 2; }
session=01;bold_override="";conf_override="";mode=run;overwrite=0
while(( $# ));do case "$1" in --session)session="$2";shift 2;;--bold)bold_override="$2";shift 2;;--confounds)conf_override="$2";shift 2;;--dry-run)mode=dry-run;shift;;--render-only)mode=render-only;shift;;--overwrite)overwrite=1;shift;;-h|--help)usage;exit 0;;*)echo "ERROR: unknown argument: $1" >&2;exit 2;;esac;done
session="$(normalize_session "$session")";require_target_fwhm;type=act
stem="sub-${sub}_ses-${session}_task-sharedreward_run-${run}"
data="${bold_override:-$(harmonized_bold "$sub" "$session" "$run")}";confounds="${conf_override:-${CONFOUNDS_ROOT}/sub-${sub}/${stem}_desc-TedanaPlusConfounds.tsv}"
ev="$(sharedreward_ev_prefix "$sub" "$session" "$run")";template="${PROJECT_ROOT}/templates/L1_task-sharedreward_model-1_type-act.fsf";output="$(l1_output_base "$sub" "$session" "$run" act)";outdir="${FSL_DERIVATIVES_ROOT}/sub-${sub}/ses-${session}"
required=(event_computer_punish event_computer_neutral event_computer_reward event_friend_punish event_friend_neutral event_friend_reward event_stranger_punish event_stranger_neutral event_stranger_reward computer_non-face friend_face stranger_face)
for name in "${required[@]}";do [[ -s "${ev}_${name}.txt" ]]||{ echo "ERROR: required EV missing: ${ev}_${name}.txt" >&2;exit 1;};done
[[ -f "$data" ]]||{ echo "ERROR: target-smoothed BOLD missing: $data" >&2;exit 1;};[[ -s "$confounds" ]]||{ echo "ERROR: confounds missing: $confounds" >&2;exit 1;};[[ -f "$template" ]]||{ echo "ERROR: template missing: $template" >&2;exit 1;}
shape_dec=10;shape_out=10;[[ -s "${ev}_missed_decision.txt" ]]&&shape_dec=3;[[ -s "${ev}_missed_outcome.txt" ]]&&shape_out=3
printf 'L1 activation plan\n  BOLD: %s\n  confounds: %s\n  EV prefix: %s\n  target FWHM: %s mm\n  FEAT smoothing: 0 mm\n  output: %s.feat\n' "$data" "$confounds" "$ev" "$TARGET_FWHM_MM" "$output"
[[ "$mode" == dry-run ]]&&exit 0
for cmd in fslnvols fslval;do command -v "$cmd">/dev/null||{ echo "ERROR: $cmd is unavailable; load FSL" >&2;exit 1;};done
nvol="$(fslnvols "$data")";tr="$(fslval "$data" pixdim4)";[[ "$nvol" =~ ^[0-9]+$ ]]||{ echo 'ERROR: invalid nvolumes' >&2;exit 1;};awk -v x="$tr" 'BEGIN{exit !(x>0)}'||{ echo 'ERROR: invalid TR' >&2;exit 1;}
featdir="${output}.feat"
if [[ -e "$featdir" ]]; then
  if (( ! overwrite )); then [[ -f "$featdir/cluster_mask_zstat1.nii.gz" && -f "$featdir/stats/cope34.nii.gz" ]] && { echo "Complete output exists; skipping: $featdir"; exit 0; }; echo "ERROR: incomplete output exists; use --overwrite: $featdir" >&2; exit 1; fi
  case "$featdir" in "$FSL_DERIVATIVES_ROOT"/*) rm -rf -- "$featdir" ;; *) echo 'ERROR: refusing removal outside derivative root' >&2; exit 1 ;; esac
fi
mkdir -p "$outdir";rendered="${outdir}/L1_sub-${sub}_task-sharedreward_ses-${session}_model-1_type-act_run-${run}.fsf"
esc(){ printf '%s' "$1"|sed 's/[&@\\]/\\&/g'; }
sed -e "s@OUTPUT@$(esc "$output")@g" -e "s@DATA@$(esc "$data")@g" -e "s@CONFOUNDEVS@$(esc "$confounds")@g" -e "s@EVDIR@$(esc "$ev")@g" -e "s/NVOLUMES/$nvol/g" -e "s/TR_INFO/$tr/g" -e "s/SHAPE_MISSED_DECISION/$shape_dec/g" -e "s/SHAPE_MISSED_OUTCOME/$shape_out/g" "$template">"$rendered"
if grep -En 'OUTPUT|DATA|CONFOUNDEVS|EVDIR|NVOLUMES|TR_INFO|SHAPE_MISSED' "$rendered">/dev/null;then echo "ERROR: unresolved placeholder: $rendered" >&2;exit 1;fi
echo "Rendered: $rendered";[[ "$mode" == render-only ]]&&exit 0
command -v feat>/dev/null||{ echo 'ERROR: feat unavailable' >&2;exit 1;};feat "$rendered"
[[ -n "${FSLDIR:-}" && -f "$FSLDIR/etc/flirtsch/ident.mat" ]]||{ echo 'ERROR: FSLDIR identity matrix unavailable' >&2;exit 1;};mkdir -p "$featdir/reg";ln -sfn "$FSLDIR/etc/flirtsch/ident.mat" "$featdir/reg/example_func2standard.mat";ln -sfn "$FSLDIR/etc/flirtsch/ident.mat" "$featdir/reg/standard2example_func.mat";ln -sfn "$featdir/mean_func.nii.gz" "$featdir/reg/standard.nii.gz"
rm -f -- "$featdir/stats/res4d.nii.gz" "$featdir/stats/corrections.nii.gz" "$featdir/stats/threshac1.nii.gz" "$featdir/filtered_func_data.nii.gz"
