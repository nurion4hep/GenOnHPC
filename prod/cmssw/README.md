# Production using CMSSW
MC generation can be done using the CMSSW.
This is more traditional way of MC generation based on the batch or grid system,
but let us have this alternative method.

## Install CMSSW environment
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

## Dump Generator level information from CMS MINIAODSIM samples
The GeneratorInterface/LHEInterface package contains various helper modules.
Among them, we will use LHEWriter module to dump the LHE event content
and header from the MINIAODSIM input file.

Due to the limtation of the exisitng LHEWriter module, we introduced
a minor fix to the LHEWriter.cc source code and configuration file.
The .cc and cfg.py files are available in this repository.
```
git-cms-addpkg GeneratorInterface/LHEInterface
cp ../../lheWriter/LHEWriter.cc GeneratorInterface/LHEInterface/plugins/LHEWriter.cc
cp ../../lheWriter/testWriter_cfg.py GeneratorInterface/LHEInterface/test/testWriter_cfg.py
scram b -j

cd GeneratorInterface/LHEInterface/test
cmsRun testWriter_cfg.py
```

out.lhe will be produced.

## Produce MC samples with CMSSW

