#!/usr/bin/env python
import sys, os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
import time

ctimes = []
mtimes = []
rtimes = []
nevents = []
for dName in sys.argv[1:]:
    if not os.path.exists(dName+'/run.sh') or \
       not os.path.exists(dName+'/timelog.csv'): continue
    ctime = os.path.getctime(dName+'/run.sh')
    mtime = os.path.getmtime(dName+'/timelog.csv')
    lines = open(dName+'/timelog.csv').readlines()
    if len(lines) != 2: continue
    _, n, t, *_ = lines[-1].split(',')
    n, t = int(n), float(t)

    ctimes.append(int(ctime))
    mtimes.append(int(mtime))
    rtimes.append(int(t))
    nevents.append(n)

ctimes = np.array(ctimes, dtype='datetime64[s]')
mtimes = np.array(mtimes, dtype='datetime64[s]')
rtimes = np.array(rtimes, dtype='timedelta64[s]')
nevents = np.array(nevents, dtype=np.int32)

idx = np.argsort(mtimes)
ctimes = ctimes[idx]
mtimes = mtimes[idx]
rtimes = rtimes[idx]
nevents = nevents[idx]

dts = mtimes-ctimes.min()
dts = dts.astype('timedelta64[m]')

nevents = np.concatenate([[0], nevents])
dts = np.concatenate([[0], dts])

plt.grid()
plt.plot(dts, np.cumsum(nevents), '-k')
plt.xlabel('Elapsed time (min)')
plt.ylabel('Produced events')
plt.show()

#plt.grid()
#plt.plot((mtimes-ctimes).astype('timedelta64[m]'), '.-')
#plt.plot(rtimes.astype('timedelta64[m]'), '.-')
#plt.xlabel('Index')
#plt.ylabel('Elapsed time per section (min)')
#plt.show()
