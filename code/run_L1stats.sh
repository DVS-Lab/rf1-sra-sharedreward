#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"
nruns=2
task=sharedreward # edit if necessary

# create log file to record what we did and when
logs=$maindir/logs
logfile=${logs}/rerunL1_date-`date +"%FT%H%M"`.log


for ppi in 0 "VS_thr5"; do # # putting 0 first will indicate "activation"
	for model in 2 3; do
		for sub in `cat ${scriptdir}/newsubs.txt`; do
	  		for run in `seq $nruns`; do

			# some exceptions, hopefully temporary
			#if [ $sub -eq 3223 ]; then # bad data ||[ $sub -eq 3164 ] ||[ $sub -eq 1300 ] ||[ $sub -eq 1253 ]
			#	echo "skipping both runs for sub-${sub} for task-${task}"
			#	continue
			#fi
			#if [ $sub -eq 1002 ] ||[ $sub -eq 1003 ] || [ $sub -eq 3186 ] || [ $sub -eq 3210 ] || [ $sub -eq 3218 ] || [ $sub -eq 3152 ] && [ $run -eq 2 ]; then # bad data
			#	echo "skipping run-2 for sub-${sub} for task-${task}"
			#	continue
			#fi

	  	# Manages the number of jobs and cores
	  		SCRIPTNAME=${maindir}/code/L1stats.sh
	  		NCORES=15
	  		while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
	    			sleep 5s
	  		done
	  		bash $SCRIPTNAME $model $sub $run $ppi $logfile &
				sleep 1s
	  	done
	  done
	done
done
