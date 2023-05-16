#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# create log file to record what we did and when
logs=$maindir/logs
logfile=${logs}/rerunL2_date-`date +"%FT%H%M"`.log

# the "type" variable below is setting a path inside the main script
for type in "ppi_seed-VS_thr5"; do # "act" ppi_seed-VS_thr5 ppi_seed-NAcc act nppi-ecn nppi-dmn
	#for sub in 1001 1004 1006 1007 1009 1010 1011 1012 1013 1015 1016 1019 1021 1242 1243 1244 1248 1249 1251 1255 1276 1282 1286 1294 1301 1302 1303 3116 3122 3125 3140 3143 3166 3167 3170 3173 3176 3189 3190 3199 3200 3206 3212 3220; do
	for sub in `cat ${scriptdir}/newsubs.txt`; do

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
