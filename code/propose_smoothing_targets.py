#!/usr/bin/env python3
"""Summarize baseline classic FWHM and evaluate candidate isotropic targets."""
from __future__ import annotations
import argparse, csv, math, statistics
from collections import defaultdict
from pathlib import Path
def percentile(v,p):
 v=sorted(v); x=(len(v)-1)*p; lo=math.floor(x); hi=math.ceil(x); return v[lo] if lo==hi else v[lo]*(hi-x)+v[hi]*(x-lo)
def main():
 p=argparse.ArgumentParser(description=__doc__); p.add_argument('--input',required=True,type=Path); p.add_argument('--output',required=True,type=Path); p.add_argument('--min',type=float); p.add_argument('--max',type=float); p.add_argument('--step',type=float,default=.5); a=p.parse_args()
 rows=list(csv.DictReader(a.input.open(),delimiter='\t')); by=defaultdict(list)
 for r in rows:
  value=r.get('classic_fwhm_combined') or r.get('pre_resample_smoothness')
  if value not in (None,'','n/a'):by[r['dataset']].append(float(value))
 if not by:p.error('no dataset/classic_fwhm_combined values found')
 observed=[x for v in by.values() for x in v]; low=a.min if a.min is not None else math.floor(min(observed)*2)/2; high=a.max if a.max is not None else math.ceil(max(observed)*2)/2+2
 a.output.parent.mkdir(parents=True,exist_ok=True)
 with a.output.open('w',newline='') as h:
  fields=['dataset','target_mm','n_runs','median','iqr','min','max','p90','p95','n_already_smoother','pct_already_smoother','median_additional_gaussian_mm']
  w=csv.DictWriter(h,fieldnames=fields,delimiter='\t',lineterminator='\n'); w.writeheader(); t=low
  while t<=high+1e-8:
   for dataset,v in sorted(by.items()):
    already=sum(x>t for x in v); add=[math.sqrt(max(0,t*t-x*x)) for x in v]
    w.writerow({'dataset':dataset,'target_mm':f'{t:.2f}','n_runs':len(v),'median':f'{statistics.median(v):.4f}','iqr':f'{percentile(v,.75)-percentile(v,.25):.4f}','min':f'{min(v):.4f}','max':f'{max(v):.4f}','p90':f'{percentile(v,.9):.4f}','p95':f'{percentile(v,.95):.4f}','n_already_smoother':already,'pct_already_smoother':f'{100*already/len(v):.2f}','median_additional_gaussian_mm':f'{statistics.median(add):.4f}'})
   t+=a.step
 print(f'Candidate table: {a.output}'); return 0
if __name__=='__main__':raise SystemExit(main())
