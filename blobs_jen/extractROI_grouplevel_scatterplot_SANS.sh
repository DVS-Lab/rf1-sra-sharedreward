#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

 # ROI name and other path information
for ROI in nppi-dmn_model-14_cnum-11_con13_z2; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/SANS/${ROI}.nii.gz
	TASK=sharedreward
	TYPE="nppi-dmn"	
	N=93 # remember to change according to the model
	model_N=14 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/SANS
	mkdir -p $outputdir
	
	for COPENUM in 11; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done

for ROI in nppi-dmn_model-14_cnum-10_con15_z1; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/SANS/${ROI}.nii.gz
	TASK=sharedreward
	TYPE="nppi-dmn"
	N=93 # remember to change according to the model
	model_N=14 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/SANS
	mkdir -p $outputdir
	
	for COPENUM in 10; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done

for ROI in nppi-dmn_model-13_cnum-11_con5_z1; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/SANS/${ROI}.nii.gz
	TASK=sharedreward
	TYPE="nppi-dmn"
	N=93 # remember to change according to the model
	model_N=13 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/SANS
	mkdir -p $outputdir
	
	for COPENUM in 11; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done

for ROI in nppi-dmn_model-13_cnum-10_con6_z1; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/SANS/${ROI}.nii.gz
	TASK=sharedreward
	TYPE="nppi-dmn"
	N=93 # remember to change according to the model
	model_N=13 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/SANS
	mkdir -p $outputdir
	
	for COPENUM in 10; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done

for ROI in thr_seed-VS; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/SANS/${ROI}.nii.gz
	TASK=sharedreward
	TYPE=act
	N=93 # remember to change according to the model
	model_N=1 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/SANS
	mkdir -p $outputdir
	
	for COPENUM in 11 10; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done

for ROI in thr_seed-VS; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/SANS/${ROI}.nii.gz
	TASK=sharedreward
	TYPE="nppi-dmn"
	N=93 # remember to change according to the model
	model_N=1 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/SANS
	mkdir -p $outputdir
	
	for COPENUM in 10 11; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done