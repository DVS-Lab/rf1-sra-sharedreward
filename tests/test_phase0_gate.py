import os,subprocess,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class GateTest(unittest.TestCase):
 def test_target_unset_fails(self):
  env=os.environ.copy();env.pop('TARGET_FWHM_MM',None);r=subprocess.run(['bash','-c',f'source "{ROOT}/code/project_config.sh"; require_target_fwhm'],env=env,capture_output=True,text=True);self.assertNotEqual(r.returncode,0);self.assertIn('Phase 0',r.stderr)
if __name__=='__main__':unittest.main()
