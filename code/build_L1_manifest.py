#!/usr/bin/env python3
"""Build a session/run-aware RF1 Shared Reward L1 readiness manifest."""
from __future__ import annotations
import argparse,csv,os,re
from pathlib import Path
EVENT_RE=re.compile(r'^sub-(?P<subject>[^_]+)_ses-(?P<session>[^_]+)_task-sharedreward_run-(?P<run>[^_]+)_events\.tsv$')
def read_sublist(path):
 v=[]
 for raw in path.read_text().splitlines():
  x=raw.split('#',1)[0].strip().removeprefix('sub-')
  if x:v.append(x)
 return sorted(dict.fromkeys(v))
def paths(subject,session,run,bids,fmriprep,confounds):
 stem=f'sub-{subject}_ses-{session}_task-sharedreward_run-{run}'
 func=fmriprep/f'sub-{subject}'/f'ses-{session}'/'func'
 return (bids/f'sub-{subject}'/f'ses-{session}'/'func'/f'{stem}_events.tsv',
 func/f'{stem}_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz',
 func/f'{stem}_part-mag_space-MNI152NLin6Asym_desc-brain_mask.nii.gz',
 confounds/f'sub-{subject}'/f'{stem}_desc-TedanaPlusConfounds.tsv')
def write(path,header,rows):
 path.parent.mkdir(parents=True,exist_ok=True)
 with path.open('w',newline='') as h:
  w=csv.writer(h,delimiter='\t',lineterminator='\n'); w.writerow(header); w.writerows(rows)
def main():
 root=Path(__file__).resolve().parents[1]; upstream=Path(os.environ.get('RF1_SRA_UPSTREAM_ROOT','/ZPOOL/data/projects/rf1-sra-linux2'))
 p=argparse.ArgumentParser(description=__doc__); p.add_argument('--bids-root',type=Path,default=Path(os.environ.get('BIDS_ROOT',upstream/'bids'))); p.add_argument('--fmriprep-root',type=Path,default=Path(os.environ.get('FMRIPREP_ROOT',upstream/'derivatives/fmriprep'))); p.add_argument('--confounds-root',type=Path,default=Path(os.environ.get('CONFOUNDS_ROOT',upstream/'derivatives/fsl/confounds_tedana'))); p.add_argument('--sublist',type=Path); p.add_argument('--sessions',default='01'); p.add_argument('--output',type=Path,default=root/'logs/runlists/L1-ready.tsv'); p.add_argument('--missing-output',type=Path,default=root/'logs/runlists/L1-missing.tsv'); a=p.parse_args()
 if not a.bids_root.is_dir():p.error(f'BIDS root not found: {a.bids_root}')
 subjects=read_sublist(a.sublist) if a.sublist else sorted(x.name.removeprefix('sub-') for x in a.bids_root.glob('sub-*') if x.is_dir()); sessions=[x.strip().removeprefix('ses-') for x in a.sessions.split(',') if x.strip()]
 ready=[]; missing=[]
 for sub in subjects:
  for ses in sessions:
   func=a.bids_root/f'sub-{sub}'/f'ses-{ses}'/'func'
   if not func.is_dir():missing.append((sub,ses,'','missing BIDS session func directory')); continue
   runs=[]
   for f in sorted(func.glob(f'sub-{sub}_ses-{ses}_task-sharedreward_run-*_events.tsv')):
    m=EVENT_RE.match(f.name)
    if m:runs.append(m.group('run'))
   if not runs:missing.append((sub,ses,'','no canonical Shared Reward events')); continue
   for run in sorted(dict.fromkeys(runs),key=lambda x:(not x.isdigit(),int(x) if x.isdigit() else x)):
    ps=paths(sub,ses,run,a.bids_root,a.fmriprep_root,a.confounds_root); absent=[n for n,f in zip(('events','BOLD','mask','confounds'),ps) if not f.is_file() or f.stat().st_size==0]
    (missing if absent else ready).append((sub,ses,run,','.join(absent)) if absent else (sub,ses,run))
 write(a.output,('subject','session','run'),ready); write(a.missing_output,('subject','session','run','reason'),missing)
 paired=sum({r for s,se,r in ready if s==sub and se==ses}>={'1','2'} for sub,ses in {(s,se) for s,se,_ in ready})
 print(f'Subjects considered: {len(subjects)}\nReady Shared Reward L1 runs: {len(ready)}\nSubject-sessions with runs 1 and 2: {paired}\nMissing-input rows: {len(missing)}\nReady manifest: {a.output.resolve()}\nMissing report: {a.missing_output.resolve()}')
 return 0 if ready else 1
if __name__=='__main__':raise SystemExit(main())
