#!/usr/bin/env python3
"""Audit RF1 Shared Reward fMRIPrep BOLD grids and write a JSON/TSV inventory."""
from __future__ import annotations
import argparse, csv, hashlib, json
from collections import Counter
from pathlib import Path
import numpy as np

def signature(img):
    import nibabel as nib
    return {'shape':list(img.shape[:3]),'zooms':[float(x) for x in img.header.get_zooms()[:3]],
            'orientation':''.join(nib.aff2axcodes(img.affine)),'affine':np.asarray(img.affine).round(7).tolist(),
            'qform_code':int(img.header['qform_code']),'sform_code':int(img.header['sform_code'])}
def key(s): return json.dumps(s,sort_keys=True,separators=(',',':'))
def main():
    p=argparse.ArgumentParser(description=__doc__); p.add_argument('--fmriprep-root',required=True,type=Path); p.add_argument('--output-prefix',required=True,type=Path); a=p.parse_args()
    try: import nibabel as nib
    except ImportError as e: p.error(f'nibabel is required: {e}')
    files=sorted(a.fmriprep_root.glob('sub-*/ses-*/func/sub-*_ses-*_task-sharedreward_run-*_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz'))
    if not files: p.error('no canonical Shared Reward BOLD files found')
    records=[]; counts=Counter()
    for f in files:
      s=signature(nib.load(f)); counts[key(s)]+=1; records.append({'path':str(f.resolve()),**s})
    modal_key,modal_n=counts.most_common(1)[0]; modal=json.loads(modal_key)
    for r in records:r['matches_modal']=key({k:r[k] for k in modal})==modal_key
    a.output_prefix.parent.mkdir(parents=True,exist_ok=True)
    js=a.output_prefix.with_suffix('.json'); ts=a.output_prefix.with_suffix('.tsv')
    js.write_text(json.dumps({'n_files':len(files),'n_unique_grids':len(counts),'modal_count':modal_n,'modal_grid':modal,'files':records},indent=2)+'\n')
    with ts.open('w',newline='') as h:
      w=csv.writer(h,delimiter='\t',lineterminator='\n'); w.writerow(['path','shape','zooms','orientation','qform_code','sform_code','matches_modal'])
      for r in records:w.writerow([r['path'],'x'.join(map(str,r['shape'])),'x'.join(map(str,r['zooms'])),r['orientation'],r['qform_code'],r['sform_code'],str(r['matches_modal']).lower()])
    print(f'Files: {len(files)}\nUnique grids: {len(counts)}\nModal grid files: {modal_n}\nJSON: {js}\nTSV: {ts}')
    return 0 if len(counts)==1 else 1
if __name__=='__main__': raise SystemExit(main())
