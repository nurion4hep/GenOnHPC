#!/usr/bin/env python
import sys
import numpy as np
#from ROOT import *
import matplotlib.pyplot as plt

import pandas as pd
#df0 = pd.read_csv("timelog.csv")
df0 = pd.read_csv(sys.argv[1])
df0 = df0.rename(columns={'ncpus':'nCPUs', 'nevts':'nEvents'})
#df0 = df0[df0.nEvents <= 10000]
nCPUsList = sorted(df0.nCPUs.unique())
nEventsList = sorted(df0.nEvents.unique())

def drawErrorBar(xVar, yVar, label):
    xVals = sorted(xVar.unique())
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
for nEvents in nEventsList:
    df = df0[df0.nEvents == nEvents]
    xs = df.nCPUs
    tReal = df.real
    tUser = df.user
    tSyst = df.sys

    plt.grid(linestyle='--', alpha=0.5, which='both')
    #plt.yscale('log')
    #plt.xscale('log')
    plt.xlabel('Number of Processors (nEventss=%d)' % nEvents)
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
for nCPUs in nCPUsList:
    df = df0[df0.nCPUs == nCPUs]
    drawErrorBar(df.nEvents, df.real, 'nCPUs=%d' % nCPUs)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Processors')
plt.ylabel('Time (s)')
for nEvents in nEventsList:
    df = df0[df0.nEvents == nEvents]
    drawErrorBar(df.nCPUs, df.real, 'nEvents=%d' % nEvents)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Events')
plt.ylabel('Event rate (Hz)')
for nCPUs in nCPUsList:
    df = df0[df0.nCPUs == nCPUs]
    rate = df.nEvents/df.real
    drawErrorBar(df.nEvents, rate, 'nCPUs=%d' % nCPUs)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Processors')
plt.ylabel('Event rate (Hz)')
for nEvents in nEventsList:
    df = df0[df0.nEvents == nEvents]
    rate = nEvents/df.real
    drawErrorBar(df.nCPUs, rate, 'nEvents=%d' % nEvents)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Events')
plt.ylabel('Event rate per processor (Hz)')
for nCPUs in nCPUsList:
    df = df0[df0.nCPUs == nCPUs]
    rate = df.nEvents/df.real/nCPUs
    drawErrorBar(df.nEvents, rate, 'nCPUs=%d' % nCPUs)
plt.legend()
plt.tight_layout()
plt.show()

plt.grid(linestyle='--', alpha=0.5, which='both')
#plt.yscale('log')
#plt.xscale('log')
plt.xlabel('Number of Processors')
plt.ylabel('Event rate per processor (Hz)')
for nEvents in nEventsList:
    df = df0[df0.nEvents == nEvents]
    rate = nEvents/df.real/df.nCPUs
    drawErrorBar(df.nCPUs, rate, 'nEvents=%d' % nEvents)
plt.legend()
plt.tight_layout()
plt.show()

"""grp = TGraph()
for i, (n, t) in enumerate(zip(nCPUss, tReal)):
    grp.SetPoint(i, n, t)

hFrame = TH1F("hFrame", ";Number of processes;Real Time(s)", 70, 0, 70)
hFrame.SetMinimum(0)
hFrame.SetMaximum(1.5*max(tReal))
hFrame.Draw()
grp.Draw("LP")
"""
