# How to dump Generator level information from CMS MINIAODSIM samples
## Installing CMSSW environment
This step has to be done once to initialize your workspace

If your system is shipped with the cvmfs, you can use the common singularity images
to set up your base CMSSW.
```
source /cvmfs/cms.cern.ch/cmsset_default.sh 
cmssw-cc7
```

After entering the CMSSW's singularity environment, run the following steps
to initialize your workspace.

```
CMSSW_VERSION=CMSSW_12_2_0
if [ -d $CMSSW_VERSION ]; then
  echo "CMSSW already installed: $CMSSW_VERSION"
  exit
fi

cmsrel $CMSSW_VERSION
cd $CMSSW_VERSION/src
cmsenv
git-cms-init
```

Then, set up Generator related packages.
```
git-cms-addpkg GeneratorInterface/LHEInterface
scram b -j
```


