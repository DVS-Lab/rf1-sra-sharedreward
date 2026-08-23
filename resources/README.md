# RF1 reference grid

The authoritative resource is generated on Linux2 with `code/create_reference_grid.py` after `code/audit_rf1_grid.py` confirms that all eligible RF1 Shared Reward runs share one spatial grid within the documented affine tolerance and carry the modal MNI qform/sform matrices and intent codes.

Expected files:

- `rf1_MNI152NLin6Asym_reference_grid.nii.gz`: zero-valued 3D NIfTI containing no participant signal.
- `rf1_MNI152NLin6Asym_reference_grid.json`: dimensions, voxel sizes, affine, orientation, qform/sform codes, source provenance, commands, software versions, and SHA256.

The NIfTI is intentionally not fabricated from a guessed TemplateFlow resolution. It must be created from the verified modal current Linux2 output. Until that resource exists, downstream grid matching and production smoothing should fail.
