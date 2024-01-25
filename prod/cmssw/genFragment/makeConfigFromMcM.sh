#!/bin/bash
if [ $# -lt 1 ]; then
    echo "!!! Usage: $0 MC_PRODUCTION_CAMPAIGN"
    echo "      example: $0 TOP-RunIISummer20UL18wmLHEGEN-00003"
    exit 1
fi
#CAMPAIGN=TOP-RunIISummer20UL18wmLHEGEN-00003
CAMPAIGN=$1

echo "@@@ Checking CMSSW..."
if [ _$CMSSW_BASE == _ ]; then
    echo "!!! CMSSW is not set. Please install CMSSW working area and run cmsenv"
    exit 1
fi

## Download Gen-fragment from McM
echo "@@@ Downloading Gen-fragment from the McM"
BASEURL=https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_fragment
GENPRODDIR=Configuration/GenProduction
GENFRAGMNT=$CMSSW_BASE/src/$GENPRODDIR/python/$CAMPAIGN-fragment.py
if [ -f $GENFRAGMNT ]; then
    echo "... gen-fragment $GENFRAGMNT already exists."
else
    curl -s -k $BASEURL/$CAMPAIGN --retry 3 --create-dirs -o $GENFRAGMNT
    if [ ! -s $GENFRAGMNT ]; then
        echo "!!! Gen fragment could not be written..."
        exit 2
    fi
fi

## Check gridpack
if grep -q "gridpacks" $GENFRAGMNT; then
    if ! grep -q "/cvmfs/cms.cern.ch/phys_generator/gridpacks" $GENFRAGMNT; then
        echo "!!! This gen-fragment is based on gridpack,"
        echo "    but there's no gridpack in the CVMFS."
        exit 2
    fi
fi

## Write CMSSW configuration file from the fragment
echo "@@@ Writing configuration file from the gen-fragment..."
ERA=Run2_2018 ### This does nothing for the generation step
## NEVENT Taken from @slowmoyang
# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 3.4910s
# Threads for each sequence: 1
# Time per event for single thread for each sequence: 1 * 3.4910s = 3.4910s
# Which adds up to 3.4910s per event
# Single core events that fit in validation duration: 20160s / 3.4910s = 5774
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 5774 and 10000, but more than 0 -> 5774
# It is estimated that this validation will produce: 5774 * 1.0000 = 5774 events
#NEVENT=5774
NEVENT=10
\cp customise_*.py $CMSSW_BASE/src/Configuration/GenProduction/python
cd $CMSSW_BASE/src/Configuration
scram b -j
cd -
GENCONFIG=${CAMPAIGN}_cfg.py
if [ -f $GENCONFIG ]; then
    echo "... configuration file $GENCONFIG already exists."
else
    #--step LHE,GEN --eventcontent RAWSIM,LHE --datatier GEN,LHE \
    cmsDriver.py $GENPRODDIR/python/$CAMPAIGN-fragment.py --no_exec --mc -n $NEVENT \
                 --step LHE,GEN --eventcontent GEN --datatier GEN \
                 --conditions auto:mc --geometry DB:Extended --era $ERA \
                 --python_filename ${GENCONFIG} \
                 --fileout file:${CAMPAIGN}.root \
                 --customise Configuration/DataProcessing/Utils.addMonitoring \
                 --customise Configuration/GenProduction/customise_generation.customise_nEventsInLumi \
                 --customise Configuration/GenProduction/customise_generation.customise_random \
                 --customise Configuration/GenProduction/customise_generation.customise_messageLogger \
                 --customise Configuration/GenProduction/customise_generation.customise_pruneGenParticles
fi
