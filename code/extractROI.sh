#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"
outputdir=${maindir}/derivatives/imaging_plots
TASK=sharedreward
MAINOUTPUT=${maindir}/derivatives/fsl/L3_model-2_task-${TASK}_n45_flame1_SFN_edition
mkdir -p $outputdir


	# ROI name and other path information
for ROI in act_C14_rew_F-S_z2_sub; do

#seed-VS_thr5; do #activation

#ppi ROIs: #seed-pTPJ-thr seed-vmPFC-5mm-thr seed-mPFC-thr; do

#ppi exploratory: #ppi_C10_FS-C_z8_sub-neg_cluster1 ppi_C10_FS-C_z8_sub-neg_cluster2 ppi_C13_rew-pun_F-C_z12_su-rs2_cluster1 ppi_C13_rew-pun_F-C_z1_main-effect ppi_C16_rew_F-C_z1_main-effect_cluster1 ppi_C16_rew_F-C_z1_main-effect_cluster2 ppi_C21_rew_F-SC_z1_main-effect ppi_C23_rew-pun_F-SC_z12_sub-neg_cluster1 ppi_c9_F-C_sub-neg; do
	for TASK in sharedreward; do
		MASK=${maindir}/masks/${ROI}.nii
		#MASK=${maindir}/masks/seed-${ROI}.nii.gz
		TYPE=act #ppi_seed-VS_thr5
		for COPENUM in 1 2 3 4 5 6; do
			cnum_padded=`zeropad ${COPENUM} 2`
			DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_type-${TYPE}_cnum-${cnum_padded}_*.gfeat/cope1.feat/filtered_func_data.nii.gz`
			fslmeants -i $DATA -o ${outputdir}/${ROI}_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}
		done	
	done
done
