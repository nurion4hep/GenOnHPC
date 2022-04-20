#!/bin/bash
#PBS -V
#PBS -q normal
#PBS -A etc
#PBS -N powheg.hvq-TT.8cpu
#PBS -l select=1:ncpus=8:mpiprocs=1:ompthreads=8
#PBS -l walltime=04:00:00

######## Parameters to be defined by user ########
[ -z $NEVTS ] && NEVTS=1000
[ -z $SIF ] && SIF=/scratch/hpc22a02/singularity/powheg.sif
[ -z $LHAPDFSETS ] && LHAPDFSETS=/scratch/hpc22a02/lhapdfsets/current
#ARCHIVE=hvq_TT
ARCHIVE=`echo $PBS_JOBNAME | awk -F. '{if(NF>1){print $2}else{print $1}}'` ## powheg.ARCHIVE_FILE_NAME.other.fields
[ -z $PWHG_MAIN ] && PWHG_MAIN=/sw/POWHEG-BOX-V2/`echo $ARCHIVE | awk -F- '{print $1}'`/pwhg_main
SEEDBASE=1000
##################################################

##################################################
[ -z $PBS_ARRAY_INDEX ] && PBS_ARRAY_INDEX=0
[ -z $NCPUS ] || export OMP_NUM_THREADS=$NCPUS
[ -z $OMP_NUM_THREADS ] && export OMP_NUM_THREADS=64 ## For the case of NCPUS and OMP_NUM_THREADS undefined
[ -z $PBS_JOBNAME ] && PBS_JOBNAME=powheg.TT-hvq
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
#mkdir -p $OUTDIR/Events

cd $OUTDIR
cp $PBS_O_WORKDIR/Cards/$ARCHIVE.input powheg.input
cp $PBS_O_WORKDIR/prod/$ARCHIVE/*.dat ./
sed -ie "s; *numevts .*;numevts $NEVTS;g" powheg.input
sed -ie "s; *iseed .*;iseed $SEED1;g" powheg.input
sed -ie "s; *randomseed .*;randomseed $SEED1;g" powheg.input

echo "nCPUs,nEvents,real,user,sys,maxRAM" > timelog.csv
/usr/bin/time -f"${OMP_NUM_THREADS},${NEVTS},%e,%U,%S,%M" -a -o timelog.csv \
                  singularity exec -B$LHAPDFSETS:/lhapdfsets \
                  $SIF $PWHG_MAIN

echo ARGS=$*
echo -ne "NPROC="
nproc


