#!/bin/bash

# This run_* script is a wrapper for L3stats.sh, so it will loop over several
# copes and models. Note that Contrast N for PPI is always PHYS in these models.


# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

## create log file to record what we did and when
#logs=$maindir/logs
#logfile=${logs}/rerunL3_date-`date +"%FT%H%M"`.log

# this loop defines the different types of analyses that will go into the group comparisons
	for analysis in act; do
#	for analysis in ppi_seed-NAcc-bin; do
	analysistype=type-${analysis}
#	 these define the cope number (copenum) and cope name (copename)
# use below for ppi L3
#	for copeinfo in "1 C_pun" "2 C_rew" "3 F_pun" "4 F_rew" "5 S_pun" "6 S_rew" "7 C_neu" "8 F_neu" "9 S_neu" "10 rew-pun" "11 F-S" "12 F-C" "13 FS-C" "14 rew-pun_F-S" "15 rew-pun_S-C" "16 rew-pun_F-C" "17 rew_F-S" "18 rew_S-C" "19 rew_F-C" "20 rew-neu_F-S" "21 rew-neu_S-C" "22 reu-neu_F-C" "23 F-SC" "24 rew_F-SC" "25 pun_F-SC" "26 rew_pun_F-SC" "27 F_dec" "28 S_dec" "29 C_dec" "30 Face-NonFace" "31 phys" ; do	
# use below for act L3
  for copeinfo in "1 C_pun" "2 C_rew" "3 F_pun" "4 F_rew" "5 S_pun" "6 S_rew" "7 C_neu" "8 F_neu" "9 S_neu" "10 rew-pun" "11 F-S" "12 F-C" "13 FS-C" "14 rew-pun_F-S" "15 rew-pun_S-C" "16 rew-pun_F-C" "17 rew_F-S" "18 rew_S-C" "19 rew_F-C" "20 rew-neu_F-S" "21 rew-neu_S-C" "22 reu-neu_F-C" "23 F-SC" "24 rew_F-SC" "25 pun_F-SC" "26 rew_pun_F-SC" "27 F_dec" "28 S_dec" "29 C_dec" "30 Face-NonFace" "31 pun_F-S" "32 pun_F-C" "33 dec_F-S" "34 dec_F-C"; do
# old copes
#	for copeinfo in "1 C_pun" "2 C_rew" "3 F_pun" "4 F_rew" "5 S_pun" "6 S_rew" "7 C_neu" "8 F_neu" "9 S_neu" "10 rew-pun" "11 F-S" "12 F-C" "13 FS-C" "14 rew-pun_F-S" "15 rew-pun_S-C" "16 rew-pun_F-C" "17 rew_F-S" "18 rew_S-C" "19 rew_F-C" "20 rew-neu_F-S" "21 rew-neu_S-C" "22 reu-neu_F-C" "23 F-SC" "24 rew_F-SC" "25 pun_F-SC" "26 rew_pun_F-SC" "27 F_dec" "28 S_dec" "29 C_dec" "30 Face-NonFace"; do

		# split copeinfo variable
		set -- $copeinfo
		copenum=$1
		copename=$2

		if [ "${analysistype}" == "type-act" ] && [ "${copeinfo}" == "23 phys" ]; then
			echo "skipping phys for activation since it does not exist..."
			continues
		fi

		NCORES=20
		SCRIPTNAME=${maindir}/code/L3stats.sh
		while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
			sleep 1s
		done
		bash $SCRIPTNAME $copenum $copename $analysistype & # $logfile #&
		sleep 1s
		echo "complete ${copeinfo} ${analysistype}"
	done
done
