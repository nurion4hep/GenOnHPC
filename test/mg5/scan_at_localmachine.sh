#!/bin/bash
## Emulate job submission

#ARCHIVE=tttt_NLO4.tgz
ARCHIVE=TTTT_5f_NLO.tgz
export SIF=/store/sw/singularity/mg5/mg5_amc_2.9.9.sif
export LHAPDFSETS=/store/sw/hep/lhapdfsets/current
export PBS_O_WORKDIR=`pwd`
export PBS_JOBID=1000
INDEX0=0
NJOBS=5

for NCPUS in 64 48 32 24 16 12 8 4 2 1; do
    export NCPUS
    export OMP_NUM_THREADS=$NCPUS
    for NEVTS in 1 10 20 50 100 200 500 1000 2000 5000 10000; do
        export NEVTS
        export PBS_JOBID=$(($PBS_JOBID+1))

        for PBS_ARRAY_INDEX in `seq $INDEX0 $(($INDEX0+$NJOBS-1))`; do
            export PBS_ARRAY_INDEX
            export PBS_JOBNAME=madgraph.${ARCHIVE/.tgz/}.nCPUs_${NCPUS}__nEvents_${NEVTS}.${PBS_JOBID}.pbs.`printf %04d ${PBS_ARRAY_INDEX}`
            if [ -d $PBS_JOBNAME ]; then
                if [ ! -f $PBS_JOBNAME/timelog.csv ]; then
                    rm -rf $PBS_JOBNAME
                elif [ `cat $PBS_JOBNAME/timelog.csv | wc -l` -ne 2 ]; then
                    rm -rf $PBS_JOBNAME
                else
                    continue
                fi
            fi
            ./generate.sh &
        done
    done
done
