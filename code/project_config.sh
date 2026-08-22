#!/usr/bin/env bash

# Shared paths and naming for the downstream RF1 Shared Reward workflow.
# Source this file; do not execute it directly.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
UPSTREAM_ROOT="${RF1_SRA_UPSTREAM_ROOT:-/ZPOOL/data/projects/rf1-sra-linux2}"
BIDS_ROOT="${BIDS_ROOT:-${UPSTREAM_ROOT}/bids}"
FMRIPREP_ROOT="${FMRIPREP_ROOT:-${UPSTREAM_ROOT}/derivatives/fmriprep}"
CONFOUNDS_ROOT="${CONFOUNDS_ROOT:-${UPSTREAM_ROOT}/derivatives/fsl/confounds_tedana}"
FSL_DERIVATIVES_ROOT="${FSL_DERIVATIVES_ROOT:-${PROJECT_ROOT}/derivatives/fsl}"
HARMONIZED_ROOT="${HARMONIZED_ROOT:-${PROJECT_ROOT}/derivatives/harmonized}"
QC_ROOT="${QC_ROOT:-${PROJECT_ROOT}/derivatives/qc}"
REFERENCE_GRID="${REFERENCE_GRID:-${PROJECT_ROOT}/resources/rf1_MNI152NLin6Asym_reference_grid.nii.gz}"
# No default is intentional. Phase 0 must precede production smoothing/L1.
TARGET_FWHM_MM="${TARGET_FWHM_MM:-}"

normalize_subject() { printf '%s\n' "${1#sub-}"; }
normalize_session() { printf '%s\n' "${1#ses-}"; }

require_target_fwhm() {
    [[ -n "$TARGET_FWHM_MM" ]] || {
        echo "ERROR: TARGET_FWHM_MM is unset; Phase 0 target approval is required." >&2
        return 1
    }
    [[ "$TARGET_FWHM_MM" =~ ^[0-9]+([.][0-9]+)?$ ]] || {
        echo "ERROR: TARGET_FWHM_MM must be a positive numeric value." >&2
        return 1
    }
    awk -v x="$TARGET_FWHM_MM" 'BEGIN { exit !(x > 0) }' || {
        echo "ERROR: TARGET_FWHM_MM must be greater than zero." >&2
        return 1
    }
}

target_label() {
    require_target_fwhm >/dev/null
    printf '%s' "$TARGET_FWHM_MM" | sed 's/\.0*$//; s/\./p/g'
}

sharedreward_ev_prefix() {
    local sub session run
    sub="$(normalize_subject "$1")"; session="$(normalize_session "$2")"; run="$3"
    printf '%s/EVfiles/sub-%s/ses-%s/sharedreward/run-%s\n' \
        "$FSL_DERIVATIVES_ROOT" "$sub" "$session" "$run"
}

canonical_bold() {
    local sub session run stem
    sub="$(normalize_subject "$1")"; session="$(normalize_session "$2")"; run="$3"
    stem="sub-${sub}_ses-${session}_task-sharedreward_run-${run}"
    printf '%s/sub-%s/ses-%s/func/%s_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz\n' \
        "$FMRIPREP_ROOT" "$sub" "$session" "$stem"
}

harmonized_bold() {
    local sub session run label stem
    sub="$(normalize_subject "$1")"; session="$(normalize_session "$2")"; run="$3"
    label="$(target_label)"; stem="sub-${sub}_ses-${session}_task-sharedreward_run-${run}"
    printf '%s/sub-%s/ses-%s/func/%s_space-MNI152NLin6Asym_desc-smoothToFWHM%s_bold.nii.gz\n' \
        "$HARMONIZED_ROOT" "$sub" "$session" "$stem" "$label"
}

l1_output_base() {
    local sub session run type label
    sub="$(normalize_subject "$1")"; session="$(normalize_session "$2")"; run="$3"; type="$4"
    label="$(target_label)"
    printf '%s/sub-%s/ses-%s/L1_task-sharedreward_ses-%s_model-1_type-%s_run-%s_smTo-%s\n' \
        "$FSL_DERIVATIVES_ROOT" "$sub" "$session" "$session" "$type" "$run" "$label"
}

l2_output_base() {
    local sub session type label
    sub="$(normalize_subject "$1")"; session="$(normalize_session "$2")"; type="$3"
    label="$(target_label)"
    printf '%s/sub-%s/ses-%s/L2_task-sharedreward_ses-%s_model-1_type-%s_smTo-%s\n' \
        "$FSL_DERIVATIVES_ROOT" "$sub" "$session" "$session" "$type" "$label"
}

cope_count_for_type() {
    case "$1" in act) printf '34\n' ;; *) return 1 ;; esac
}
