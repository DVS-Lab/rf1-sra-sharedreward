#!/usr/bin/env bash

set -euo pipefail
usage() { echo "Usage: BIDSto3col.sh EVENTS_TSV OUTPUT_PREFIX" >&2; }
(( $# == 2 )) || { usage; exit 2; }
events="$1"; prefix="$2"
[[ -s "$events" ]] || { echo "ERROR: events file missing or empty: $events" >&2; exit 1; }
mkdir -p "$(dirname "$prefix")"

awk -F '\t' -v prefix="$prefix" '
BEGIN { OFS="\t" }
NR == 1 {
    sub(/\r$/, "")
    for (i=1; i<=NF; i++) {
        if ($i == "onset") onset=i
        if ($i == "duration") duration=i
        if ($i == "trial_type") type=i
    }
    if (!onset || !duration || !type) {
        print "ERROR: events must contain onset, duration, and trial_type columns" > "/dev/stderr"; exit 2
    }
    next
}
{
    sub(/\r$/, "")
    if ($onset !~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/ ||
        $duration !~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/ || $duration + 0 < 0) {
        printf "ERROR: invalid timing at events row %d\n", NR > "/dev/stderr"; exit 3
    }
    label=$type; gsub(/[[:space:]]+/, "_", label)
    if (label !~ /^[A-Za-z0-9_.-]+$/) {
        printf "ERROR: unsafe trial_type at events row %d: %s\n", NR, $type > "/dev/stderr"; exit 4
    }
    out=prefix "_" label ".txt"
    printf "%s\t%s\t1\n", $onset, $duration >> out; close(out)
}
END { if (NR < 2) { print "ERROR: events file contains no data rows" > "/dev/stderr"; exit 5 } }
' "$events"
