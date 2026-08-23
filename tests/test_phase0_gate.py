import os,subprocess,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class GateTest(unittest.TestCase):
 def test_approved_target_defaults_to_six(self):
  env=os.environ.copy();env.pop('TARGET_FWHM_MM',None);r=subprocess.run(['bash','-c',f'source "{ROOT}/code/project_config.sh"; require_target_fwhm; printf "%s" "$TARGET_FWHM_MM"'],env=env,capture_output=True,text=True);self.assertEqual(r.returncode,0);self.assertEqual(r.stdout,'6')
 def test_invalid_target_still_fails(self):
  env=os.environ.copy();env['TARGET_FWHM_MM']='0';r=subprocess.run(['bash','-c',f'source "{ROOT}/code/project_config.sh"; require_target_fwhm'],env=env,capture_output=True,text=True);self.assertNotEqual(r.returncode,0);self.assertIn('greater than zero',r.stderr)
if __name__=='__main__':unittest.main()
