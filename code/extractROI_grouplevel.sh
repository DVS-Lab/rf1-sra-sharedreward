#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# ROI name and other path information
for ROI in VS_thr5; do
	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	TASK=sharedreward
	TYPE=act
	outputdir=${maindir}/derivatives/imaging_plots
	mkdir -p $outputdir

	for COPENUM in 1 2; do
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_model-3_task-${TASK}_n45_flame1_SFN_edition
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done
