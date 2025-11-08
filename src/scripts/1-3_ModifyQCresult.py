# 2-1_ModifyQCresult.py

import re
import sys
import numpy as np

args = sys.argv

sample = np.array(['sample'])
both = np.array(['\nBoth surviving'])
f = np.array(['\nForward only surviving'])
r = np.array(['\nReverse only surviving'])
drop = np.array(['\nDropped'])

with open(args[1]) as i:

  for line in i:
    if re.compile('^# start ').search(line):
      line = line.rstrip('\n')
      name = re.findall('#\sstart\s(.*)', line)
      sample = np.append(sample, name)

    elif re.compile('^Input').search(line):
      num_both = re.findall('Both\sSurviving:\s(\d+)\s\(', line)
      both = np.append(both, num_both)
      #print(both)

      num_f = re.findall('Forward\sOnly\sSurviving:\s(\d+)\s\(', line)
      f = np.append(f, num_f)

      num_r = re.findall('Reverse\sOnly\sSurviving:\s(\d+)\s\(', line)
      r = np.append(r, num_r)

      num_drop = re.findall('Dropped:\s(\d+)\s\(', line)
      drop = np.append(drop, num_drop)

    else:
      next

drop = np.append(drop, '')

all = np.concatenate([sample, both, f, r, drop])

with open(args[2], mode='w') as o:
    o.write('\t'.join(all))
