#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# ROI name and other path information
for ROI in cname34_z7_c1; do

#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/${ROI}.nii.gz
	TASK=sharedreward
	TYPE=act
	model_N=13
	outputdir=${maindir}/derivatives/group_means/${ROI}
	mkdir -p $outputdir
	
	for COPENUM in 34; do # 53001
		cnum_padded=`zeropad ${COPENUM} 2`

		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done
	