#!/usr/bin/env python
import sys, os
from glob import glob
import pandas as pd

if len(sys.argv) < 2:
    print("Usage: %s DIRECTORY1 DIRECTORY2...")
    sys.exit()

data = {
    "ncpus":[], "nevts":[],
    "real":[], "user":[], "sys":[]
}

fNames = []
for dName in sys.argv[1:]:
    for fName in glob(os.path.join(dName,"*/time.log")):
        fNames.append(fName)

for f in fNames:
    if '.' not in f or '__' not in f: continue
    d = {}
    for item in (f.split("/")[0].split(".")[2]).split("__"):
        item = item.split('_')
        if len(item) != 2:
            print("Skipping item", item)
            continue
        varName, value = item
        varName = varName.lower()
        value = int(value)
        d[varName] = value

    for item in open(f).readlines():
        item = item.strip().split()
        if len(item) != 2:
            print("Skipping item", item)
            continue
        varName, value = item
        varName = varName.lower()
        value = float(value)
        d[varName] = value

    for column in data.keys():
        x = None
        if column in d: x = d[column]
        data[column].append(x)

df = pd.DataFrame(data)
print(df)

df.to_csv("time.csv")
