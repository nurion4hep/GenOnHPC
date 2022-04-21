#!/bin/bash
## Emulate job submission

#ARCHIVE=TTTT_4f_NLO.tgz
ARCHIVE=TTTT_5f_NLO.tgz
export SIF=/store/sw/singularity/mg5/mg5_amc_2.9.9.sif
export LHAPDFSETS=/store/sw/hep/lhapdfsets/current
export NJOBS=5
export JOBSTART=1000
export JOBPREFIX=madgraph
export JOBSUFFIX=""

for NCPUS in 64 48 32 24 16 12 8 4 2 1; do
    export NCPUS
    export OMP_NUM_THREADS=$NCPUS
    for NEVENT in 1 2 5 10 20 50 100 200 500 1000 2000 5000 10000; do
        export NEVENT
        export JOBSTART
        export JOBSUFFIX=NCPUS_${NCPUS}__NEVENT_${NEVENT}
        ./prepare.sh $ARCHIVE

        JOBSTART=$(($JOBSTART+$NJOBS))
    done
done
