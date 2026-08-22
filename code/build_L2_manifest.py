#!/usr/bin/env python3
"""Build fixed-effects L2 readiness from complete run-1 and run-2 activation outputs."""
from __future__ import annotations
import argparse,csv,os
from pathlib import Path
def target_label(v):return v.rstrip('0').rstrip('.').replace('.','p') if '.' in v else v
def main():
 root=Path(__file__).resolve().parents[1];p=argparse.ArgumentParser(description=__doc__);p.add_argument('--fsl-root',type=Path,default=Path(os.environ.get('FSL_DERIVATIVES_ROOT',root/'derivatives/fsl')));p.add_argument('--sublist',required=True,type=Path);p.add_argument('--sessions',default='01');p.add_argument('--target-fwhm',default=os.environ.get('TARGET_FWHM_MM'));p.add_argument('--output',type=Path,default=root/'logs/runlists/L2-ready.tsv');p.add_argument('--missing-output',type=Path,default=root/'logs/runlists/L2-missing.tsv');a=p.parse_args()
 if not a.target_fwhm:
  p.error('--target-fwhm or TARGET_FWHM_MM is required')
 label=target_label(a.target_fwhm)
 subs=sorted(dict.fromkeys(x.split('#',1)[0].strip().removeprefix('sub-') for x in a.sublist.read_text().splitlines() if x.split('#',1)[0].strip()))
 sessions=[x.strip().removeprefix('ses-') for x in a.sessions.split(',') if x.strip()]
 ready=[];missing=[]
 for sub in subs:
  for ses in sessions:
   absent=[]
   for run in ('1','2'):
    d=a.fsl_root/f'sub-{sub}'/f'ses-{ses}'/f'L1_task-sharedreward_ses-{ses}_model-1_type-act_run-{run}_smTo-{label}.feat'
    if not (d/'cluster_mask_zstat1.nii.gz').is_file() or not (d/'stats/cope34.nii.gz').is_file():absent.append(f'run-{run}')
   (missing if absent else ready).append((sub,ses,','.join(absent)) if absent else (sub,ses))
 for path,header,rows in ((a.output,('subject','session'),ready),(a.missing_output,('subject','session','missing_l1'),missing)):
  path.parent.mkdir(parents=True,exist_ok=True)
  with path.open('w',newline='') as h:w=csv.writer(h,delimiter='\t',lineterminator='\n');w.writerow(header);w.writerows(rows)
 print(f'Ready subject-sessions: {len(ready)}\nIncomplete subject-sessions: {len(missing)}');return 0
if __name__=='__main__':raise SystemExit(main())
