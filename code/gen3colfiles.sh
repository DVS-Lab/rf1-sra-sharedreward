#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/project_config.sh"
usage() { echo "Usage: gen3colfiles.sh --subject ID --run ID [--session 01] [--dry-run] [--overwrite]" >&2; }
subject=""; session=01; run=""; dry_run=0; overwrite=0
while (( $# )); do case "$1" in
    --subject) subject="$2"; shift 2 ;; --session) session="$2"; shift 2 ;;
    --run) run="$2"; shift 2 ;; --dry-run) dry_run=1; shift ;;
    --overwrite) overwrite=1; shift ;; -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown argument: $1" >&2; usage; exit 2 ;;
esac; done
[[ -n "$subject" && -n "$run" ]] || { usage; exit 2; }
subject="$(normalize_subject "$subject")"; session="$(normalize_session "$session")"
stem="sub-${subject}_ses-${session}_task-sharedreward_run-${run}"
events="${BIDS_ROOT}/sub-${subject}/ses-${session}/func/${stem}_events.tsv"
prefix="$(sharedreward_ev_prefix "$subject" "$session" "$run")"; target_dir="$(dirname "$prefix")"
[[ -s "$events" ]] || { echo "ERROR: canonical events missing or empty: $events" >&2; exit 1; }
printf 'Shared Reward EV plan\n  events: %s\n  output: %s_[trial_type].txt\n' "$events" "$prefix"
(( dry_run )) && exit 0
existing=("${prefix}"_*.txt)
if (( ${#existing[@]} )) && (( ! overwrite )); then
    echo "ERROR: EV files already exist; use --overwrite: $target_dir" >&2; exit 1
fi
parent="$(dirname "$target_dir")"; mkdir -p "$parent"
tmp="$(mktemp -d "${parent}/.sharedreward-ev.XXXXXX")"
trap 'rm -rf -- "$tmp"' EXIT
tmp_prefix="${tmp}/run-${run}"
bash "${SCRIPT_DIR}/BIDSto3col.sh" "$events" "$tmp_prefix"
required=(
 event_computer_punish event_computer_neutral event_computer_reward
 event_friend_punish event_friend_neutral event_friend_reward
 event_stranger_punish event_stranger_neutral event_stranger_reward
 computer_non-face friend_face stranger_face
)
missing=(); for ev in "${required[@]}"; do [[ -s "${tmp_prefix}_${ev}.txt" ]] || missing+=("$ev"); done
if (( ${#missing[@]} )); then
    printf 'ERROR: required non-miss EV categories are absent: %s\n' "${missing[*]}" >&2
    echo "The workflow will not invent task conditions." >&2; exit 1
fi
mkdir -p "$target_dir"; rm -f -- "${prefix}"_*.txt
for generated in "${tmp_prefix}"_*.txt; do mv -- "$generated" "$target_dir/"; done
echo "Wrote Shared Reward EVs: $target_dir"
