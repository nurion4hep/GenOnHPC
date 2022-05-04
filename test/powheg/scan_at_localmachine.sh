#!/bin/bash
## Emulate job submission

#ARCHIVE=prod/hvq-TT.tgz
ARCHIVE=prod/fourtops-TTTT.tgz
export SIF=/store/sw/singularity/powheg/powheg.sif
export LHAPDFSETS=/store/sw/hep/lhapdfsets/current
export NJOBS=5
export JOBSTART=1000
export JOBPREFIX=powheg
export JOBSUFFIX=""

export NCPUS=1
export OMP_NUM_THREADS=$NCPUS
for NEVENT in 1 10 20 50 100 200 500 1000 2000 5000 10000; do
#for NEVTS in 10000 20000 50000 100000; do
    export NEVENT
    export JOBSTART
    export JOBSUFFIX=NCPUS_${NCPUS}__NEVENT_${NEVENT}
    ./prepare.sh $ARCHIVE

    JOBSTART=$(($JOBSTART+$NJOBS))
done

