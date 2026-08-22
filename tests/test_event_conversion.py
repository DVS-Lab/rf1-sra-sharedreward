import subprocess,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class EventTest(unittest.TestCase):
 def test_canonical_events_and_distinct_misses(self):
  types=['event_computer_punish','event_computer_neutral','event_computer_reward','event_friend_punish','event_friend_neutral','event_friend_reward','event_stranger_punish','event_stranger_neutral','event_stranger_reward','computer_non-face','friend_face','stranger_face','missed_decision','missed_outcome']
  with tempfile.TemporaryDirectory() as d:
   d=Path(d);ev=d/'events.tsv';ev.write_text('onset\tduration\ttrial_type\n'+''.join(f'{i}\t0.5\t{x}\n' for i,x in enumerate(types)));prefix=d/'run-1';subprocess.run(['bash',str(ROOT/'code/BIDSto3col.sh'),str(ev),str(prefix)],check=True)
   for i,x in enumerate(types):self.assertEqual((d/f'run-1_{x}.txt').read_text(),f'{i}\t0.5\t1\n')
   self.assertFalse((d/'run-1_computer_non-faceclea.txt').exists())
if __name__=='__main__':unittest.main()
