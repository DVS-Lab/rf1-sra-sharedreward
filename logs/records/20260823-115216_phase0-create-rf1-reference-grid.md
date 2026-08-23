# Run Record: phase0-create-rf1-reference-grid

- Timestamp: 20260823-115216
- Branch: main
- Commit: e47eec4
- Host: CLA19787.tu.temple.edu
- User: tug87422
- Working directory: `/ZPOOL/data/projects/rf1-sra-sharedreward`
- Raw log: `/ZPOOL/data/projects/rf1-sra-sharedreward/logs/runs/20260823-115216_phase0-create-rf1-reference-grid.log`
- Command exit: 0
- Check exit: 0
- Summary: CHECK PASSED: reference grid is a zero-valued 3D image: (57, 70, 54)

## Command

```bash
/ZPOOL/data/tools/anaconda/tug87422/envs/sharedreward-phase0/bin/python code/create_reference_grid.py --source /ZPOOL/data/projects/rf1-sra-linux2/derivatives/fmriprep/sub-10317/ses-01/func/sub-10317_ses-01_task-sharedreward_run-1_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz --output resources/rf1_MNI152NLin6Asym_reference_grid.nii.gz --json-output resources/rf1_MNI152NLin6Asym_reference_grid.json 
```

## Check

```bash
/ZPOOL/data/tools/anaconda/tug87422/envs/sharedreward-phase0/bin/python -c import\ nibabel\ as\ nib\,numpy\ as\ np\,sys\;\ i=nib.load\(sys.argv\[1\]\)\;\ assert\ i.ndim==3\ and\ np.count_nonzero\(np.asanyarray\(i.dataobj\)\)==0\;\ print\(\"CHECK\ PASSED:\ reference\ grid\ is\ a\ zero-valued\ 3D\ image:\"\,\ i.shape\) resources/rf1_MNI152NLin6Asym_reference_grid.nii.gz 
```

## Log

```text
RUN START: 20260823-115216
PROJECT_ROOT: /ZPOOL/data/projects/rf1-sra-sharedreward
GIT: main e47eec4
HOST: CLA19787.tu.temple.edu
USER: tug87422
PWD: /ZPOOL/data/projects/rf1-sra-sharedreward
COMMAND: /ZPOOL/data/tools/anaconda/tug87422/envs/sharedreward-phase0/bin/python code/create_reference_grid.py --source /ZPOOL/data/projects/rf1-sra-linux2/derivatives/fmriprep/sub-10317/ses-01/func/sub-10317_ses-01_task-sharedreward_run-1_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz --output resources/rf1_MNI152NLin6Asym_reference_grid.nii.gz --json-output resources/rf1_MNI152NLin6Asym_reference_grid.json 

{
  "template_space": "MNI152NLin6Asym",
  "dimensions": [
    57,
    70,
    54
  ],
  "voxel_sizes_mm": [
    2.700000047683716,
    2.700000047683716,
    2.9700000286102295
  ],
  "orientation": "RAS",
  "affine": [
    [
      2.700000047683716,
      0.0,
      0.0,
      -74.80000305175781
    ],
    [
      0.0,
      2.700000047683716,
      0.0,
      -109.80000305175781
    ],
    [
      0.0,
      0.0,
      2.9700000286102295,
      -72.0
    ],
    [
      0.0,
      0.0,
      0.0,
      1.0
    ]
  ],
  "qform_code": 4,
  "sform_code": 4,
  "source_provenance": "/ZPOOL/data/projects/rf1-sra-linux2/derivatives/fmriprep/sub-10317/ses-01/func/sub-10317_ses-01_task-sharedreward_run-1_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz",
  "contains_participant_signal": false,
  "date_generated": "2026-08-23T15:52:16.536153+00:00",
  "software": {
    "python": "3.11.16",
    "nibabel": "5.4.2"
  },
  "command": "create_reference_grid.py --source <verified-modal-RF1-BOLD>",
  "sha256": "52fd69e09e50ffe857b25a62afb9b8c4fc31f8b3cad9942a6a6874ff5b067bcf"
}

COMMAND EXIT: 0

CHECK COMMAND: /ZPOOL/data/tools/anaconda/tug87422/envs/sharedreward-phase0/bin/python -c import\ nibabel\ as\ nib\,numpy\ as\ np\,sys\;\ i=nib.load\(sys.argv\[1\]\)\;\ assert\ i.ndim==3\ and\ np.count_nonzero\(np.asanyarray\(i.dataobj\)\)==0\;\ print\(\"CHECK\ PASSED:\ reference\ grid\ is\ a\ zero-valued\ 3D\ image:\"\,\ i.shape\) resources/rf1_MNI152NLin6Asym_reference_grid.nii.gz 

CHECK PASSED: reference grid is a zero-valued 3D image: (57, 70, 54)

CHECK EXIT: 0
```
