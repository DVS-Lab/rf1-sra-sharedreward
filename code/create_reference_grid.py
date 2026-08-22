#!/usr/bin/env python3
"""Create a zero-valued non-participant grid NIfTI and provenance JSON."""
from __future__ import annotations
import argparse, datetime, hashlib, json, platform
from pathlib import Path
import numpy as np
def sha256(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__); p.add_argument('--source',required=True,type=Path); p.add_argument('--output',required=True,type=Path); p.add_argument('--json-output',required=True,type=Path); a=p.parse_args()
 try: import nibabel as nib
 except ImportError as e:p.error(f'nibabel is required: {e}')
 src=nib.load(a.source); data=np.zeros(src.shape[:3],dtype=np.uint8); hdr=src.header.copy(); hdr.set_data_dtype(np.uint8); hdr.set_data_shape(data.shape)
 out=nib.Nifti1Image(data,src.affine,hdr); q,qc=src.get_qform(coded=True); s,sc=src.get_sform(coded=True); out.set_qform(q,int(qc)); out.set_sform(s,int(sc))
 a.output.parent.mkdir(parents=True,exist_ok=True); nib.save(out,a.output)
 re=nib.load(a.output); assert np.count_nonzero(np.asanyarray(re.dataobj))==0
 meta={'template_space':'MNI152NLin6Asym','dimensions':list(re.shape),'voxel_sizes_mm':[float(x) for x in re.header.get_zooms()[:3]],
 'orientation':''.join(nib.aff2axcodes(re.affine)),'affine':re.affine.tolist(),'qform_code':int(re.header['qform_code']),'sform_code':int(re.header['sform_code']),
 'source_provenance':str(a.source.resolve()),'contains_participant_signal':False,'date_generated':datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'software':{'python':platform.python_version(),'nibabel':nib.__version__},'command':'create_reference_grid.py --source <verified-modal-RF1-BOLD>', 'sha256':sha256(a.output)}
 a.json_output.write_text(json.dumps(meta,indent=2)+'\n'); print(json.dumps(meta,indent=2)); return 0
if __name__=='__main__':raise SystemExit(main())
