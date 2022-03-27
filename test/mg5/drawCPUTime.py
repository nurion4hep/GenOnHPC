#!/usr/bin/env python
import numpy as np
#from ROOT import *
import matplotlib.pyplot as plt

import pandas as pd
df0 = pd.read_csv("timelog.csv")
#df0 = df0[df0.nEvent <= 10000]
nProcList = df0.nProc.unique()
nEventList = df0.nEvent.unique()

def drawErrorBar(xVar, yVar, label):
    xVals = xVar.unique()
    nx = len(xVals)
    yVals = np.zeros(nx)
    yErrs = np.zeros(nx)

    for i, x in enumerate(xVals):
        ys = yVar[xVar == x]
        yVals[i] = ys.mean()
        yErrs[i] = ys.std() if not np.isnan(ys.std()) else ys.mean()

    plt.errorbar(xVals, yVals, yerr=yErrs,
                 label=label, marker='o', markersize=3)
"""
for nEvent in nEventList:
    df = df0[df0.nEvent == nEvent]
    xs = df.nProc
    tReal = df.real
    tUser = df.user
    tSyst = df.sys

    plt.grid(linestyle='--', alpha=0.5, which='both')
    #plt.yscale('log')
    #plt.xscale('log')
    plt.xlabel('Number of Processors (nEvents=%d)' % nEvent)
    plt.ylabel('Time (s)')

    plt.plot(xs, tReal, '.-', label='Real')
    plt.plot(xs, tUser, '.-', label='User')
    plt.plot(xs, tSyst, '.-', label='Sys')
    plt.legend()

    plt.tight_layout()
    plt.show()
"""

plt.grid(linestyle='--', alpha=0.5, which='both')
plt.xlabel('Number of Events')
plt.ylabel('Time (s)')
for nProc in nProcList:
    df = df0[df0.nProc == nProc]
    drawErrorBar(df.nEvent, df.real, 'nProc=%d' % nProc)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Processors')
plt.ylabel('Time (s)')
for nEvent in nEventList:
    df = df0[df0.nEvent == nEvent]
    drawErrorBar(df.nProc, df.real, 'nEvent=%d' % nEvent)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Events')
plt.ylabel('Event rate (Hz)')
for nProc in nProcList:
    df = df0[df0.nProc == nProc]
    rate = df.nEvent/df.real
    drawErrorBar(df.nEvent, rate, 'nProc=%d' % nProc)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Processors')
plt.ylabel('Event rate (Hz)')
for nEvent in nEventList:
    df = df0[df0.nEvent == nEvent]
    rate = nEvent/df.real
    drawErrorBar(df.nProc, rate, 'nEvent=%d' % nEvent)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Events')
plt.ylabel('Event rate per processor (Hz)')
for nProc in nProcList:
    df = df0[df0.nProc == nProc]
    rate = df.nEvent/df.real/nProc
    drawErrorBar(df.nEvent, rate, 'nProc=%d' % nProc)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Processors')
plt.ylabel('Event rate per processor (Hz)')
for nEvent in nEventList:
    df = df0[df0.nEvent == nEvent]
    rate = nEvent/df.real/df.nProc
    drawErrorBar(df.nProc, rate, 'nEvent=%d' % nEvent)
plt.legend()
plt.tight_layout()
plt.show()

"""grp = TGraph()
for i, (n, t) in enumerate(zip(nProcs, tReal)):
    grp.SetPoint(i, n, t)

hFrame = TH1F("hFrame", ";Number of processes;Real Time(s)", 70, 0, 70)
hFrame.SetMinimum(0)
hFrame.SetMaximum(1.5*max(tReal))
hFrame.Draw()
grp.Draw("LP")
"""
