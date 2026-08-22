#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
usage(){ echo "Usage: run_gen3colfiles.sh --manifest FILE [--jobs N] [--dry-run] [--overwrite]" >&2; }
manifest=""; jobs=8; dry=0; overwrite=0
while (( $# )); do case "$1" in --manifest) manifest="$2";shift 2;;--jobs) jobs="$2";shift 2;;--dry-run) dry=1;shift;;--overwrite) overwrite=1;shift;;-h|--help) usage;exit 0;;*) echo "ERROR: unknown argument: $1" >&2;exit 2;;esac;done
[[ -f "$manifest" && "$jobs" =~ ^[1-9][0-9]*$ ]] || { usage;exit 2; }
units=(); while IFS=$'\t' read -r sub ses run extra || [[ -n "${sub:-}" ]]; do sub="${sub%$'\r'}";ses="${ses%$'\r'}";run="${run%$'\r'}";[[ "$sub" == subject || -z "$sub" ]]&&continue;[[ -z "${extra:-}" ]]||{ echo 'ERROR: malformed manifest' >&2;exit 1;};units+=("${sub#sub-}|${ses#ses-}|$run");done < "$manifest"
(( ${#units[@]} ))||{ echo 'ERROR: no units' >&2;exit 1;}; [[ -z "$(printf '%s\n' "${units[@]}"|sort|uniq -d)" ]]||{ echo 'ERROR: duplicate units' >&2;exit 1;}
printf 'EV batch plan: %d unit(s), %d job(s)\n' "${#units[@]}" "$jobs"
pids=();labels=();fail=0
wait_one(){ local p="${pids[0]}" l="${labels[0]}";wait "$p"||{ echo "ERROR: failed EV unit: $l" >&2;fail=$((fail+1));};pids=("${pids[@]:1}");labels=("${labels[@]:1}"); }
for u in "${units[@]}"; do
  IFS='|' read -r sub ses run <<< "$u"; cmd=(bash "$SCRIPT_DIR/gen3colfiles.sh" --subject "$sub" --session "$ses" --run "$run")
  (( dry )) && cmd+=(--dry-run); (( overwrite )) && cmd+=(--overwrite)
  if (( dry )); then "${cmd[@]}" || fail=$((fail+1)); else "${cmd[@]}" & pids+=("$!"); labels+=("sub-$sub ses-$ses run-$run"); (( ${#pids[@]} >= jobs )) && wait_one; fi
done
while((${#pids[@]}));do wait_one;done;((fail==0))
