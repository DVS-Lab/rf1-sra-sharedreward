#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

 # ROI name and other path information
for ROI in n5151_cnum-17_con-8_cluster-1; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/brain_images/FourthYear/${ROI}.nii.gz
	TASK=sharedreward
	TYPE=ppi
	N=5151 # remember to change according to the model
	model_N=0 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/FourthYear/${ROI}
	mkdir -p $outputdir
	
	for COPENUM in 17; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done

for ROI in n5152_cnum-12_con-7_cluster-1; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/brain_images/FourthYear/${ROI}.nii.gz
	TASK=sharedreward
	TYPE=ppi
	N=5152 # remember to change according to the model
	model_N=0 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/FourthYear/${ROI}
	mkdir -p $outputdir
	
	for COPENUM in 12; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done

for ROI in n5153_cnum-13_con-8_cluster-1 n5153_cnum-13_con-8_cluster-2; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/brain_images/FourthYear/${ROI}.nii.gz
	TASK=sharedreward
	TYPE=ppi
	N=5153 # remember to change according to the model
	model_N=0 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/FourthYear/${ROI}
	mkdir -p $outputdir
	
	for COPENUM in 13; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done

for ROI in n5154_cnum-14_con-8_cluster-1; do
#	MASK=${maindir}/masks/seed-${ROI}.nii.gz
	MASK=${maindir}/masks/brain_images/FourthYear/${ROI}.nii.gz
	TASK=sharedreward
	TYPE=ppi
	N=5154 # remember to change according to the model
	model_N=0 # remember to change according to the model
	outputdir=${maindir}/derivatives/group_means/FourthYear/${ROI}
	mkdir -p $outputdir
	
	for COPENUM in 14; do #
		cnum_padded=`zeropad ${COPENUM} 2`
		MAINOUTPUT=${maindir}/derivatives/fsl/L3_task-${TASK}_model-${model_N}_type-${TYPE}_n${N}
		DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_*cnum-${cnum_padded}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		#DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${COPENUM}_*onegroup.gfeat/cope1.feat/filtered_func_data.nii.gz`
		fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}

	done
done