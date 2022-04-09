#!/bin/bash
#PBS -V
#PBS -q normal
#PBS -A etc
#PBS -N madgraph.TTTT0j1j_4f_LO.8cpu
#PBS -l select=1:ncpus=8:mpiprocs=1:ompthreads=8
#PBS -l walltime=04:00:00

######## Parameters to be defined by user ########
IS_REUSING_ARCHIVE=0
[ -z $NEVTS ] && NEVTS=1000
[ -z $SIF ] && SIF=/scratch/hpc22a02/singularity/mg5_amc_2.9.9.sif
[ -z $LHAPDFSETS ] && LHAPDFSETS=/scratch/hpc22a02/lhapdfsets/current
#ARCHIVE=tttt_NLO
ARCHIVE=`echo $PBS_JOBNAME | awk -F. '{if(NF>1){print $2}else{print $1}}'` ## madgraph.ARCHIVE_FILE_NAME.other.fields
SEEDBASE=1000
##################################################

##################################################
[ -z $PBS_ARRAY_INDEX ] && PBS_ARRAY_INDEX=0
[ -z $NCPUS ] || export OMP_NUM_THREADS=$NCPUS
[ -z $OMP_NUM_THREADS ] && export OMP_NUM_THREADS=64 ## For the case of NCPUS and OMP_NUM_THREADS undefined
[ -z $PBS_JOBNAME ] && PBS_JOBNAME=madgraph.TTTT0j1j_4f_LO-8CPU
SEED1=$(($SEEDBASE+$PBS_ARRAY_INDEX))
RUNNAME=`printf 'run_%04d' $PBS_ARRAY_INDEX`
export LHAPDF_DATA_PATH=/lhapdfsets
##################################################

env
echo -ne "NPROC="
nproc

echo "-------------------------"

which module
if [ $? -eq 0 ]; then
    module load singularity
    module load gcc/8.3.0
    module load mvapich2/2.3.6
fi

OUTDIR=${PBS_JOBNAME}.`echo $PBS_JOBID | sed -e 's;\[[0-9+]\];;g'`.`printf "%04d" $PBS_ARRAY_INDEX`
OUTDIR=$PBS_O_WORKDIR/$OUTDIR
mkdir -p $OUTDIR
mkdir -p $OUTDIR/Events

if [ $IS_REUSING_ARCHIVE -eq 1 ]; then
    echo "@@@ Reusing existing Madgraph directory..."
    ARCHIVE=$PBS_O_WORKDIR/$ARCHIVE
else
    echo "@@@ Extracting archive..."
    cd $OUTDIR
    tar xzf $PBS_O_WORKDIR/${ARCHIVE}.tgz
    ARCHIVE=`readlink -f ${ARCHIVE}`
fi
cd $ARCHIVE
echo "@@@ Cleaning previously produced files..."
rm -rf RunWeb Events/*
echo "nCPUs,nEvents,real,user,sys,maxRAM" > timelog.csv

echo "@@@ Replacing run cards..."
echo "@@@   nevents = $NEVTS"
echo "@@@   iseed = $SEED1"
echo "@@@   run_mode = 2"
sed -ie 's;.*= *nevents.*$;'$NEVTS' = nevents;g' Cards/run_card.dat
sed -ie 's;.*= *iseed;'$SEED1' = iseed;g' Cards/run_card.dat
if [ -f Cards/madspin_card.dat ]; then
    sed -ie "s;set max_running_process.*;set max_running_process $OMP_NUM_THREADS;g" Cards/madspin_card.dat
fi

echo "@@@ Starting singularity session to run the mg5_amc"
if [ -f Cards/me5_configuration.txt -a ! -f Cards/amcatnlo_configuration.txt ]; then
    echo "@@@ Madgraph (LO) configuration detected."
    sed -ie 's;.*run_mode *=.*$;run_mode = 2;g' Cards/me5_configuration.txt
    sed -ie 's;.*nb_core.*=.*$;nb_core = '$OMP_NUM_THREADS';g' Cards/me5_configuration.txt

    /usr/bin/time -f"${OMP_NUM_THREADS},${NEVTS},%e,%U,%S,%M" -a -o timelog.csv \
                  singularity exec -B$LHAPDFSETS:/lhapdfsets \
                  $SIF bin/generate_events $RUNNAME <<EOF
1=OFF; 2=OFF; 3=OFF; 4=OFF; 5=OFF
0
EOF

elif [ -f Cards/amcatnlo_configuration.txt -a ! -f Cards/me5_configuration.txt ]; then
    echo "@@@ aMC@NLO (NLO) configuration detected."
    sed -ie 's;.*run_mode *=.*$;run_mode = 2;g' Cards/amcatnlo_configuration.txt
    sed -ie 's;.*nb_core.*=.*$;nb_core = '$OMP_NUM_THREADS';g' Cards/amcatnlo_configuration.txt

    /usr/bin/time -f"${OMP_NUM_THREADS},${NEVTS},%e,%U,%S,%M" -a -o timelog.csv \
                  singularity exec -B$LHAPDFSETS:/lhapdfsets \
                  $SIF bin/generate_events -oxpMmf -n $RUNNAME
fi

echo ARGS=$*
echo -ne "NPROC="
nproc

mv Events/* $OUTDIR/Events/
mv timelog.csv $OUTDIR/
if [ $IS_REUSING_ARCHIVE -eq 0 ]; then
    rm -rf $ARCHIVE
fi

echo "@@@ Done"

