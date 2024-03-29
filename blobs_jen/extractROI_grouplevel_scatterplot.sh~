#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# ROI name and other path information
#for ROI in cname11_z4_c1; do
#for ROI in cname18_z4_c1; do
#for ROI in cname20_z3_c2; do
#for ROI in cname25_z3_c1; do
#for ROI in cname27_z3_c1; do
#for ROI in cname28_z4_c1; do
#for ROI in cname29_z3_c1; do
for ROI in cname34_z7_c1; do

#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/brain_images/${ROI}.nii.gz
	TASK=sharedreward
	TYPE=act
	outputdir=${maindir}/derivatives/group_means/${ROI}
	mkdir -p $outputdir
	
#	for COPENUM in 11; do # 530
#	for COPENUM in 18; do # 5300
#	for COPENUM in 20; do # 5300
#	for COPENUM in 25; do # 5300
#	for COPENUM in 27; do # 5300
#	for COPENUM in 28; do # 530
#	for COPENUM in 29; do # 5300
	for COPENUM in 34; do # 53001
		cnum_padded=`zeropad ${COPENUM} 2`
#		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n530
#		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n5300
#		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n5300
#		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n5300
#		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n5300
#		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n530
#		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n5300
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-sharedreward_model-1_type-act_n53001
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done
	