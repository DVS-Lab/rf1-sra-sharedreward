#!/usr/bin/env python3
"""Compute voxelwise mean/temporal-SD tSNR and mask summaries."""

from __future__ import annotations
import argparse, csv, json
from pathlib import Path
import numpy as np

def main() -> int:
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--input', required=True, type=Path)
    p.add_argument('--mask', required=True, type=Path, help='Run-specific brain mask')
    p.add_argument(
        '--reference-mask',
        type=Path,
        help=(
            'Optional fixed analysis mask. tSNR is summarized in its intersection '
            'with the run mask, and coverage is relative to this fixed mask.'
        ),
    )
    p.add_argument('--output-image', type=Path)
    p.add_argument('--output-json', required=True, type=Path)
    p.add_argument('--dataset', default='unknown'); p.add_argument('--subject', default='unknown')
    p.add_argument('--session', default=''); p.add_argument('--run', default=''); p.add_argument('--stage', default='unknown')
    a=p.parse_args()
    try: import nibabel as nib
    except ImportError as e: p.error(f'nibabel is required: {e}')
    img=nib.load(a.input); mask_img=nib.load(a.mask)
    if img.ndim != 4: p.error(f'input must be 4D: {a.input}')
    if mask_img.shape[:3] != img.shape[:3] or not np.allclose(mask_img.affine,img.affine,atol=1e-5):
        p.error('mask and input grids do not match')
    run_mask=np.asanyarray(mask_img.dataobj)>0
    reference_mask=None
    reference_mask_path=''
    if a.reference_mask:
      reference_img=nib.load(a.reference_mask)
      if reference_img.ndim != 3:
        p.error(f'reference mask must be 3D: {a.reference_mask}')
      if reference_img.shape != img.shape[:3] or not np.allclose(reference_img.affine,img.affine,atol=1e-5):
        p.error('reference mask and input grids do not match')
      reference_mask=np.asanyarray(reference_img.dataobj)>0
      reference_mask_path=str(a.reference_mask.resolve())
    analysis_mask=run_mask if reference_mask is None else run_mask & reference_mask
    denominator=run_mask if reference_mask is None else reference_mask
    if not np.any(denominator): p.error('mask used as coverage denominator is empty')
    if not np.any(analysis_mask): p.error('run/reference mask intersection is empty')
    data=np.asanyarray(img.dataobj,dtype=np.float32)
    mean=np.mean(data,axis=3); sd=np.std(data,axis=3,ddof=1)
    tsnr=np.zeros(mean.shape,dtype=np.float32); valid=analysis_mask & np.isfinite(mean) & np.isfinite(sd) & (sd>0)
    tsnr[valid]=mean[valid]/sd[valid]; values=tsnr[valid]
    if values.size == 0: p.error('no valid masked voxels')
    out={
      'dataset':a.dataset,'subject':a.subject,'session':a.session,'run':a.run,'stage':a.stage,
      'definition':'temporal mean / sample temporal SD (ddof=1)',
      'input':str(a.input.resolve()),'mask':str(a.mask.resolve()),
      'reference_mask':reference_mask_path,'n_volumes':img.shape[3],
      'tr_seconds':float(img.header.get_zooms()[3]),
      'run_mask_voxels':int(run_mask.sum()),
      'reference_mask_voxels':int(denominator.sum()),
      'analysis_mask_voxels':int(analysis_mask.sum()),
      'mask_voxels':int(analysis_mask.sum()),
      'valid_voxels':int(values.size),
      'coverage_pct':float(100*analysis_mask.sum()/denominator.sum()),
      'valid_coverage_pct':float(100*values.size/denominator.sum()),
      'mean_tsnr':float(np.mean(values)),'median_tsnr':float(np.median(values))
    }
    a.output_json.parent.mkdir(parents=True,exist_ok=True); a.output_json.write_text(json.dumps(out,indent=2)+'\n')
    if a.output_image:
      a.output_image.parent.mkdir(parents=True,exist_ok=True); nib.save(nib.Nifti1Image(tsnr,img.affine,img.header),a.output_image)
    print(json.dumps(out)); return 0
if __name__=='__main__': raise SystemExit(main())
