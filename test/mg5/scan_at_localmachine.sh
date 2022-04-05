#!/bin/bash
## Emulate job submission

#ARCHIVE=tttt_NLO4.tgz
export SIF=/store/sw/singularity/mg5/mg5_amc_2.9.9.sif
export PBS_O_WORKDIR=`pwd`
export PBS_ARRAY_INDEX=0
export PBS_JOBID=10000
N=3

#for NEVTS in 1 10 20 50 100 200 500 1000 2000 5000 10000 20000 50000 100000; do
for NEVTS in 1 10 20 50 100 200 500 1000 2000 5000 10000; do
    export NEVTS
    for NCPUS in 64 48 32 24 16 12 8 4 2 1; do
        export NCPUS
        export OMP_NUM_THREADS=$NCPUS

        for PBS_ARRAY_INDEX in `seq $N`; do
            export PBS_JOBID=$(($PBS_JOBID+1))
            export PBS_ARRAY_INDEX
            export PBS_JOBNAME=madgraph.TTTT_5f_NLO.nCPUs_${NCPUS}__nEvents_${NEVTS}.${PBS_JOBID}.pbs.`printf %04d ${PBS_ARRAY_INDEX}`
            ./generate.sh
        done
    done
done
