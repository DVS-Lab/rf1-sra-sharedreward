# Run Record: target-smoothing-6mm-sanity-sub-11720-run-1

- Timestamp: 20260823-173851
- Branch: main
- Commit: 0f00a8a
- Host: CLA19787.tu.temple.edu
- User: tug87422
- Working directory: `/ZPOOL/data/projects/rf1-sra-sharedreward`
- Raw log: `/ZPOOL/data/projects/rf1-sra-sharedreward/logs/runs/20260823-173851_target-smoothing-6mm-sanity-sub-11720-run-1.log`
- Command exit: 0
- Check exit: none
- Summary: COMMAND exit 0; CHECK none.

## Command

```bash
bash code/smooth_to_target.sh --input /ZPOOL/data/projects/rf1-sra-linux2/derivatives/fmriprep/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz --mask /ZPOOL/data/projects/rf1-sra-linux2/derivatives/fmriprep/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_part-mag_space-MNI152NLin6Asym_desc-brain_mask.nii.gz --output /ZPOOL/data/projects/rf1-sra-sharedreward/derivatives/harmonized/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_space-MNI152NLin6Asym_desc-smoothToFWHM6_bold.nii.gz --qc-tsv /ZPOOL/data/projects/rf1-sra-sharedreward/derivatives/harmonized/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_space-MNI152NLin6Asym_desc-smoothToFWHM6_bold_smoothness.tsv --work-dir work/target-smoothing 
```

## Log

```text
RUN START: 20260823-173851
PROJECT_ROOT: /ZPOOL/data/projects/rf1-sra-sharedreward
GIT: main 0f00a8a
HOST: CLA19787.tu.temple.edu
USER: tug87422
PWD: /ZPOOL/data/projects/rf1-sra-sharedreward
COMMAND: bash code/smooth_to_target.sh --input /ZPOOL/data/projects/rf1-sra-linux2/derivatives/fmriprep/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz --mask /ZPOOL/data/projects/rf1-sra-linux2/derivatives/fmriprep/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_part-mag_space-MNI152NLin6Asym_desc-brain_mask.nii.gz --output /ZPOOL/data/projects/rf1-sra-sharedreward/derivatives/harmonized/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_space-MNI152NLin6Asym_desc-smoothToFWHM6_bold.nii.gz --qc-tsv /ZPOOL/data/projects/rf1-sra-sharedreward/derivatives/harmonized/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_space-MNI152NLin6Asym_desc-smoothToFWHM6_bold_smoothness.tsv --work-dir work/target-smoothing 

++ 3dBlurToFWHM: AFNI version=AFNI_26.2.03 (Aug  4 2026) [64-bit]
++ Max number iterations set to 143
++ detrending blurmaster: 19 ref funcs, 255 time points
 + detrending of blurmaster complete
++ Output dataset /ZPOOL/data/projects/rf1-sra-sharedreward/work/target-smoothing/blur.wYPEGw/smoothed.nii.gz
++ 3dFWHMx: AFNI version=AFNI_26.2.03 (Aug  4 2026) [64-bit]
++ Authored by: The Bob
[7m*+ WARNING:[0m Using the 'Classic' Gaussian FWHM is not recommended :(
 +  The '-acf' method gives a FWHM estimate which is more robust;
 +  however, assuming the spatial correlation of FMRI noise has
 +  a Gaussian shape is not a good model.
++ Number of voxels in mask = 101225
++ detrending start: 19 baseline funcs, 255 time points
 + detrending done (0.00 CPU s thus far)
++ start Classic FWHM calculations
 + Classic FWHM done (0.00 CPU s thus far)
++ start ACF calculations out to radius = 17.18 mm
 + ACF done (0.00 CPU s thus far)
Smoothness: classic combined=5.72781 mm; ACF effective=9.15311 mm
Requested target: 6 mm
Runtime: 53 seconds
Output: /ZPOOL/data/projects/rf1-sra-sharedreward/derivatives/harmonized/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_space-MNI152NLin6Asym_desc-smoothToFWHM6_bold.nii.gz
QC: /ZPOOL/data/projects/rf1-sra-sharedreward/derivatives/harmonized/sub-11720/ses-01/func/sub-11720_ses-01_task-sharedreward_run-1_space-MNI152NLin6Asym_desc-smoothToFWHM6_bold_smoothness.tsv

COMMAND EXIT: 0
```
