#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)";usage(){ echo "Usage: run_L2stats.sh --manifest FILE --type act [--jobs N] [--dry-run|--render-only] [--overwrite] [--log-dir DIR]" >&2;}
manifest="";type="";jobs=20;mode=run;overwrite=0;logdir="";while(( $# ));do case "$1" in --manifest)manifest="$2";shift 2;;--type)type="$2";shift 2;;--jobs)jobs="$2";shift 2;;--dry-run)mode=dry-run;shift;;--render-only)mode=render-only;shift;;--overwrite)overwrite=1;shift;;--log-dir)logdir="$2";shift 2;;-h|--help)usage;exit 0;;*)echo "ERROR: unknown argument: $1" >&2;exit 2;;esac;done
[[ -f "$manifest" && "$type" == act && "$jobs" =~ ^[1-9][0-9]*$ ]]||{ usage;exit 2;};units=();while IFS=$'\t' read -r sub ses extra||[[ -n "${sub:-}" ]];do sub="${sub%$'\r'}";ses="${ses%$'\r'}";[[ "$sub" == subject||-z "$sub" ]]&&continue;[[ -z "${extra:-}" ]]||{ echo 'ERROR: malformed manifest' >&2;exit 1;};units+=("${sub#sub-}|${ses#ses-}");done<"$manifest";printf 'L2 batch plan: %d unit(s), %d job(s), fixed effects\n' "${#units[@]}" "$jobs";[[ -z "$logdir"||"$mode" == dry-run ]]||mkdir -p "$logdir"
pids=();labels=();logs=();fail=0;wait_one(){ local p="${pids[0]}" l="${labels[0]}" f="${logs[0]}";if ! wait "$p";then echo "ERROR: failed L2 unit: $l${f:+ (log: $f)}" >&2;fail=$((fail+1));else echo "DONE: $l";fi;pids=("${pids[@]:1}");labels=("${labels[@]:1}");logs=("${logs[@]:1}");}
for u in "${units[@]}"; do
  IFS='|' read -r sub ses <<< "$u"; label="sub-$sub ses-$ses"; cmd=(bash "$SCRIPT_DIR/L2stats.sh" "$sub" act --session "$ses")
  [[ "$mode" == dry-run ]] && cmd+=(--dry-run); [[ "$mode" == render-only ]] && cmd+=(--render-only); (( overwrite )) && cmd+=(--overwrite)
  if [[ "$mode" == dry-run ]]; then "${cmd[@]}" || fail=$((fail+1)); continue; fi
  f=""; if [[ -n "$logdir" ]]; then f="$logdir/sub-${sub}_ses-${ses}_type-act.log"; "${cmd[@]}" >"$f" 2>&1 & else "${cmd[@]}" & fi
  pids+=("$!"); labels+=("$label"); logs+=("$f"); (( ${#pids[@]} >= jobs )) && wait_one
done
while (( ${#pids[@]} )); do wait_one; done
(( fail == 0 ))
