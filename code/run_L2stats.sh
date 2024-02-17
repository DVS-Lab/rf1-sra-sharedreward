#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# create log file to record what we did and when
logs=$maindir/logs
logfile=${logs}/rerunL2_date-`date +"%FT%H%M"`.log

# the "type" variable below is setting a path inside the main script
for type in "act"; do # "act" "ppi_seed-VS_thr5"
	for sub in `cat ${scriptdir}/sublist_sfn.txt`; do

		# Manages the number of jobs and cores
  	SCRIPTNAME=${maindir}/code/L2stats.sh
  	NCORES=10
  	while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
    		sleep 1s
  	done
  	bash $SCRIPTNAME $sub $type $logfile &
  	sleep 1s

	done
done
