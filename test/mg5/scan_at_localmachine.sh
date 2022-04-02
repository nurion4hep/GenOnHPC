#!/bin/bash

ARCHIVE=tttt_NLO4.tgz
#export OMP_NUM_THREADS=64

[ -f timelog.csv ] || echo "nProc,nEvent,sys,user,real" > timelog.csv

I=0
#for NEVENTS in 1 10 20 50 100 200 500 1000 2000 5000 10000 20000 50000 100000; do 
#for NEVENTS in 1 10 20 50 100 200 500 1000 2000 5000 10000; do 
for NEVENTS in 20000 50000 100000; do 
  for NCPU in 64 48 32 24 16 12 8 4 2 1; do
    export OMP_NUM_THREADS=$NCPU
    I=$(($I+1))

    tar xzf $ARCHIVE
    cd ${ARCHIVE/.tgz/}
    /usr/bin/time -f"${OMP_NUM_THREADS},${NEVENTS},%S,%U,%e" \
                  -a -o ../timelog.csv \
                  singularity exec /store/sw/singularity/mg5/mg5_amc_2.9.9.sif ../generate.sh $I $NEVENTS
    cd ..
    rm -rf ${ARCHIVE/.tgz/}

  done
done
