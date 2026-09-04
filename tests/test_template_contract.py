import re,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class TemplateTest(unittest.TestCase):
 def test_active_templates_disable_per_ev_temporal_filtering(self):
  for path in ROOT.joinpath('templates').glob('*.fsf'):
   enabled=re.findall(r'^set fmri\(tempfilt_yn\d+\)\s+1$',path.read_text(),re.M)
   self.assertEqual(enabled,[],path.name)
 def test_activation_contract(self):
  text=(ROOT/'templates/L1_task-sharedreward_model-1_type-act.fsf').read_text();d=dict(re.findall(r'^set fmri\(([^)]+)\)\s+"?([^"\n]+)"?$',text,re.M))
  expected=['C_pun','C_rew','F_pun','F_rew','S_pun','S_rew','C_neu','F_neu','S_neu','missed_decision','missed_outcome','F_dec','S_dec','C_dec']
  self.assertEqual(int(d['evs_orig']),14);self.assertEqual(int(d['ncon_orig']),34);self.assertEqual(d['smooth'].strip(),'0');self.assertEqual([d[f'evtitle{i}'].strip() for i in range(1,15)],expected)
  self.assertEqual(d['tempfilt_yn7'].strip(),'0')
  for c in range(1,35):self.assertEqual(float(d[f'con_real{c}.10']),0);self.assertEqual(float(d[f'con_real{c}.11']),0)
 def test_no_feat_watcher(self):self.assertNotIn('set fmri(featwatcher_yn) 1',(ROOT/'templates/L1_task-sharedreward_model-1_type-act.fsf').read_text())
if __name__=='__main__':unittest.main()
