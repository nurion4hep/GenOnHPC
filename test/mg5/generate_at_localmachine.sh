#!/bin/bash

INDEX=$1
NEVTS=$2
SEED1=$((1000+$INDEX))
[ -x $OMP_NUM_THREADS ] && OMP_NUM_THREADS=`nproc`

RUNNAME=`printf 'run_%02d' $INDEX`

rm -rf RunWeb Events/*

sed -ie 's;.*= *nevents.*$;'$NEVTS' = nevents;g' Cards/run_card.dat
sed -ie 's;.*= *iseed.*$;'$SEED1' = iseed;g' Cards/run_card.dat
if [ -f Cards/me5_configuration.txt -a ! -f Cards/amcatnlo_configuration.txt ]; then
    echo "@@@ Madgraph (LO) configuration detected."
    sed -ie 's;.*run_mode *=.*$;run_mode = 2;g' Cards/me5_configuration.txt
    sed -ie 's;.*nb_core.*=.*$;nb_core = '$OMP_NUM_THREADS';g' Cards/me5_configuration.txt

    bin/generate_events $RUNNAME <<EOF
1=OFF; 2=OFF; 3=OFF; 4=OFF; 5=OFF
0
EOF

elif [ -f Cards/amcatnlo_configuration.txt -a ! -f Cards/me5_configuration.txt ]; then
    echo "@@@ aMC@NLO (NLO) configuration detected."
    sed -ie 's;.*run_mode *=.*$;run_mode = 2;g' Cards/amcatnlo_configuration.txt
    sed -ie 's;.*nb_core.*=.*$;nb_core = '$OMP_NUM_THREADS';g' Cards/amcatnlo_configuration.txt

    bin/generate_events -oxpMmf -n $RUNNAME
fi

echo ARGS=$*
echo -ne "NPROC="
nproc

echo "@@@ Done."

