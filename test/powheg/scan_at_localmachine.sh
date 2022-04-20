#!/bin/bash
## Emulate job submission

#ARCHIVE=hvq-TT.tgz
ARCHIVE=fourtops-TTTT.tgz
export SIF=/store/sw/singularity/powheg/powheg.sif
export LHAPDFSETS=/store/sw/hep/lhapdfsets/current
export PBS_O_WORKDIR=`pwd`
export PBS_JOBID=1000
INDEX0=0
NJOBS=5

export NCPUS=1
export OMP_NUM_THREADS=$NCPUS
for NEVTS in 1 10 20 50 100 200 500 1000 2000 5000 10000; do
#for NEVTS in 10000 20000 50000 100000; do
    export NEVTS
    export PBS_JOBID=$(($PBS_JOBID+1))

    for PBS_ARRAY_INDEX in `seq $INDEX0 $(($INDEX0+$NJOBS-1))`; do
        export PBS_ARRAY_INDEX
        export PBS_JOBNAME=powheg.${ARCHIVE/.tgz/}.nCPUs_${NCPUS}__nEvents_${NEVTS}.${PBS_JOBID}.pbs
        OUTDIR=${PBS_JOBNAME}.`echo $PBS_JOBID | sed -e 's;\[[0-9+]\];;g'`.`printf "%04d" $PBS_ARRAY_INDEX`
        if [ -d $OUTDIR ]; then
            echo "Skip" $OUTDIR
            continue
        fi

        ./generate.sh &
    done
done
