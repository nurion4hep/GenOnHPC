# Production using CMSSW
MC generation can be done using the CMSSW.
This is more traditional way of MC generation based on the batch or grid system,
but let us have this alternative method.

## Install CMSSW environment
This step has to be done once to initialize your workspace

If your system is shipped with the cvmfs, you can use the common singularity images
to set up your base CMSSW.
```
source /cvmfs/cms.cern.ch/cmsset\_default.sh
cmssw-cc7
```

After entering the CMSSW's singularity environment, run the following steps
to initialize your workspace.

```
CMSSW\_VERSION=CMSSW\_12\_2\_0
if [ -d $CMSSW\_VERSION ]; then
  echo "CMSSW already installed: $CMSSW\_VERSION"
  exit
fi

cmsrel $CMSSW\_VERSION
cd $CMSSW\_VERSION/src
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
cp ../../lheWriter/testWriter\_cfg.py GeneratorInterface/LHEInterface/test/testWriter\_cfg.py
scram b -j

cd GeneratorInterface/LHEInterface/test
cmsRun testWriter\_cfg.py
```

out.lhe will be produced.

## Produce MC samples with CMSSW
Samples can be produced with the CMSSW framework and gridpack.
Although the aim of this repository is building a framework to generate MC samples,
we still can rely on the standard CMSSW environment.

One can generate CMSSW configuration file, taking the gen-fragment from the McM.
```
cd genFragment
./makeConfigFromMcM.sh TOP-RunIISummer20UL18wmLHEGEN-00003
cmsRun TOP-RunIISummer20UL18wmLHEGEN-00003\_cfg.py
```
will give you .root files.

Please note that this configuration file saves minimal set of event contents
which can be used in generator level studies based on the Delphes and drop the
original GenParticle and HepMC contents.
If you need the full GenParticles and HepMC, please modify the \_cfg.py file
not to apply customization step for pruning.

## Runing Delphes Fast simulation
Detector simulation can be done with the Delphes Fast-simulation software.
Delphes suports CMSSW's GenParticles dataformat, including the prunedGenParticles
and packedGenParticles in the MiniAOD datatier.

Install the Delphes software as follows;
```
wget http://cp3.irmp.ucl.ac.be/downloads/Delphes-3.5.0.tar.gz
tar xzf Delphes-3.5.0.tar.gz

cd Delphes-3.5.0
sed -i 's/c++0x/c++17/g' Makefile
make -j

cd ..
```

Run the Delphes to do the detector simulation.

```
./Delphes-3.5.0/DelphesCMSFWLite Delphes-3.5.0/cards/delphes\_card\_CMS.tcl out.root genFragment/TOP-RunIISummer20UL18wmLHEGEN-00003.root
```
