import csv,subprocess,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class Manifests(unittest.TestCase):
 def test_l1_requires_events_bold_mask_and_confounds(self):
  with tempfile.TemporaryDirectory() as d:
   d=Path(d);b=d/'bids';f=d/'fmriprep';c=d/'conf';stem='sub-100_ses-01_task-sharedreward_run-1';func=b/'sub-100/ses-01/func';ff=f/'sub-100/ses-01/func';cc=c/'sub-100';func.mkdir(parents=True);ff.mkdir(parents=True);cc.mkdir(parents=True)
   for p in (func/f'{stem}_events.tsv',ff/f'{stem}_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz',ff/f'{stem}_part-mag_space-MNI152NLin6Asym_desc-brain_mask.nii.gz',cc/f'{stem}_desc-TedanaPlusConfounds.tsv'):p.write_text('x')
   ready=d/'ready.tsv';missing=d/'missing.tsv';subprocess.run(['python3',str(ROOT/'code/build_L1_manifest.py'),'--bids-root',str(b),'--fmriprep-root',str(f),'--confounds-root',str(c),'--output',str(ready),'--missing-output',str(missing)],check=True,capture_output=True)
   with ready.open() as handle:self.assertEqual(list(csv.reader(handle,delimiter='\t'))[-1],['100','01','1'])
 def test_l1_l2_name_contract_uses_target_label(self):
  with tempfile.TemporaryDirectory() as d:
   d=Path(d);sublist=d/'subs.txt';sublist.write_text('100\n');root=d/'fsl'
   for run in ('1','2'):
    feat=root/'sub-100/ses-01'/f'L1_task-sharedreward_ses-01_model-1_type-act_run-{run}_smTo-6p5.feat';(feat/'stats').mkdir(parents=True);(feat/'cluster_mask_zstat1.nii.gz').write_text('x');(feat/'stats/cope34.nii.gz').write_text('x')
   ready=d/'ready.tsv';missing=d/'missing.tsv';subprocess.run(['python3',str(ROOT/'code/build_L2_manifest.py'),'--fsl-root',str(root),'--sublist',str(sublist),'--target-fwhm','6.5','--output',str(ready),'--missing-output',str(missing)],check=True,capture_output=True)
   with ready.open() as handle:self.assertEqual(list(csv.reader(handle,delimiter='\t'))[-1],['100','01'])
if __name__=='__main__':unittest.main()
