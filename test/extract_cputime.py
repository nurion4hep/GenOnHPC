#!/usr/bin/env python
import sys, os
from glob import glob
import pandas as pd

if len(sys.argv) < 2:
    print("Usage: %s DIRECTORY1 DIRECTORY2...")
    sys.exit()

dfs = []
for fName in sys.argv[1:]:
    df = pd.read_csv(fName)
    dfs.append(df)
df = pd.concat(dfs)
print(df)

df.to_csv("timelog.csv")
