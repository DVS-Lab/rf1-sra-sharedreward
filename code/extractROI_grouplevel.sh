#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# ROI name and other path information
for ROI in cope10_win-lose_striatum_L_roi; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/${ROI}.nii.gz
	TASK=sharedreward
	TYPE=act
	outputdir=${maindir}/derivatives/imaging_plots
	mkdir -p $outputdir
#	for COPENUM in 10; do
#	for COPENUM in {1..6}; do
	for COPENUM in {7..9}; do
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n43
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done
	