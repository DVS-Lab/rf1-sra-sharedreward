#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

#for sub in `cat ${maindir}/code/sublist_sfn_final.txt`; do	
for sub in 10317; do	# for testing
	# ROI name and other path information
#	for ROI in seed-left_VS_rew-pun_anat seed-right_VS_rew-pun_anat; do
	for ROI in seed-rvol0003 seed-rvol0000 seed-rvol0001 seed-rvol0002 seed-rvol0004 seed-rvol0005 seed-rvol0006 seed-rvol0007 seed-rvol0008 seed-rvol0009; do
		for TASK in sharedreward; do
			for run in 1 2; do
#				MASK=${maindir}/masks/${ROI}.nii.gz
				MASK=${maindir}/masks/networkmasks/${ROI}.nii.gz
				#MASK=${maindir}/masks/seed-${ROI}.nii.gz
				fslmeants -i /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${TASK}_run-${run}_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz -m ${MASK} -o sub-${sub}_task-${TASK}_run-${run}_${ROI}.txt
				mv sub-${sub}_task-${TASK}_run-${run}_${ROI}.txt ${maindir}/derivatives/fsl/sub-${sub}/
				echo "complete ${sub} ${run} ${ROI}"
			done
		done
	done
done