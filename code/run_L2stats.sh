#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# create log file to record what we did and when
logs=$maindir/logs
logfile=${logs}/rerunL2_date-`date +"%FT%H%M"`.log

# the "type" variable below is setting a path inside the main script
#for type in "ppi_seed-eyeball_left" "ppi_seed-eyeball_right"; do
for type in "act"; do # "act" "ppi_seed-VS_thr5"
#for type in "ppi_seed-NAcc-bin"; do
	for sub in `cat ${scriptdir}/sub_BothRuns.txt`; do
#	for sub in 10827; do
		# Manages the number of jobs and cores
  	SCRIPTNAME=${maindir}/code/L2stats.sh
  	NCORES=4
  	while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
    		sleep 1s
  	done
  	bash $SCRIPTNAME $sub $type $logfile &
  	sleep 1s

	done
	echo "complete ${sub}"
done
