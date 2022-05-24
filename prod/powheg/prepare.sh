#!/bin/bash
## Prepare job submission

if [ $# -ne 1 ]; then
    echo "@@@ Usage: $0 ARCHIVE.tgz"
    echo "    Control with envvars:"
    echo "    export SIF=/scratch/hpc22a02/singularity/powheg.sif"
    echo "    export LHAPDFSETS=/scratch/hpc22a02/lhapdfsets/current"
    echo "    export PWHG_MAIN=/sw/POWHEG-BOX-V2/\$ARCHIVE/pwhg_main"
    #echo "    export NCPUS=`nproc`"
    echo "    export JOBSTART=1000"
    echo "    export NEVENT=10000"
    echo "    export NJOBS=10"
    echo "    export JOBPREFIX=powheg"
    echo "    export JOBSUFFIX=SUFFIX"
    exit
fi
ARCHIVE=$1

######## Parameters to be defined by user ########
[ -z $SIF ] && SIF=/scratch/hpc22a02/singularity/powheg.sif
[ -z $LHAPDFSETS ] && LHAPDFSETS=/scratch/hpc22a02/lhapdfsets/current
[ -z $PWHG_MAIN ] && PWHG_MAIN=/sw/POWHEG-BOX-V2/`basename $ARCHIVE | awk -F- '{print $1}'`/pwhg_main
#[ -z $NCPUS ] || export OMP_NUM_THREADS=$NCPUS

[ -z $JOBSTART ] && JOBSTART=1000
[ -z $NEVENT ] && NEVENT=10000
[ -z $NJOBS ] && NJOBS=10
[ -z $JOBPREFIX ] && JOBPREFIX=powheg
[ -z $JOBSUFFIX ] && JOBSUFFIX=""
[ -z $DORUN ] && DORUN=0

####### ENVVARS automatically re-evaluated #######
## OMP_NUM_THREADS: for the case of NCPUS and OMP_NUM_THREADS undefined
#[ -z $OMP_NUM_THREADS ] && export OMP_NUM_THREADS=64

############## Check environments ################
## Check singularity
IS_MOD_NEEDED=0
which singularity >& /dev/null
if [ $? -ne 0 ]; then
    which module >& /dev/null
    if [ $? -eq 0 ]; then
        module load singularity
        module load gcc/8.3.0
        module load mvapich2/2.3.6
        IS_MOD_NEEDED=1
    fi
fi
which singularity >& /dev/null
if [ $? -ne 0 ]; then
    echo "@@@ Singularity is not available. Stop."
    exit
fi

## Check singularity image
if [ ! -f $SIF ]; then
    echo "@@@ Singularity image file is not available. Stop."
    echo "    SIF=$SIF"
    exit
fi

## Check LHAPDF
if [ ! -d $LHAPDFSETS ]; then
    echo "@@@ LHAPDF is not available. Stop."
    echo "    LHAPDFSETS=$LHAPDFSETS"
    exit
fi

## Check archive tgz file
if [ ! -f $ARCHIVE ]; then
    echo "@@@ Generator archive file is not available. Stop."
    echo "    ARCHIVE=$ARCHIVE"
    exit
fi
ARBASE=`basename $ARCHIVE | sed -e 's;.tgz$;;g'`
ARCHIVE=`readlink -f $ARCHIVE`

###### Prepare job directory and run scripts ######
for IJOB in `seq $JOBSTART $(($JOBSTART+$NJOBS))`; do
    OUTDIR=${JOBPREFIX}.${ARBASE/.tgz/}.${JOBSUFFIX}.`printf %05d $IJOB`
    echo "@@@ Set output directory $OUTDIR"
    mkdir $OUTDIR
    cd $OUTDIR

    echo "@@@ Extracting archive file $ARBASE..."
    tar xzf $ARCHIVE

    echo "@@@ Writing run script..."
    cat > run.sh <<EOF
#!/bin/bash
#PBS -V
#PBS -q normal
#PBS -A etc
#PBS -N $OUTDIR
#PBS -l select=1:ncpus=1:mpiprocs=1:ompthreads=1
#PBS -l walltime=04:00:00

SIF=$SIF
export LHAPDFSETS=$LHAPDFSETS
#export OMP_NUM_THREADS=$OMP_NUM_THREADS
[ -z $OMP_NUM_THREADS ] && export OMP_NUM_THREADS=1
export LHAPDF_DATA_PATH=/lhapdfsets
RUNNAME=`printf 'run_%04d' $IJOB`
SEED1=$IJOB
NEVENT=$NEVENT

env
echo -ne "NPROC="
nproc
echo "-------------------------"
EOF

    if [ $IS_MOD_NEEDED -eq 1 ]; then
        cat >> run.sh <<EOF
module load singularity
module load gcc/8.3.0
module load mvapich2/2.3.6
EOF
    fi

    cat >> run.sh <<EOF
cd $ARBASE

echo "@@@ Cleaning previously produced files..."

sed -ie "s; *numevts .*;numevts \$NEVENT;g" powheg.input
sed -ie "s; *iseed .*;iseed \$SEED1;g" powheg.input
sed -ie "s; *randomseed .*;randomseed \$SEED1;g" powheg.input

echo "@@@ Starting singularity session to run the powheg"

/usr/bin/time -f"\${OMP_NUM_THREADS},\${NEVENT},%e,%U,%S,%M" -a -o ../timelog.csv \\
                  singularity exec -B\$LHAPDFSETS:/lhapdfsets \\
                  \$SIF ${PWHG_MAIN}

echo ARGS=$*
echo -ne "NPROC="
nproc

mv *.lhe ../
cd ..
#rm -rf $ARBASE
EOF

    chmod +x run.sh

    echo "nCPUs,nEvents,real,user,sys,maxRAM" > timelog.csv

    if [ $DORUN -eq 1 ]; then
        ./run.sh &
    fi

    cd ..    
done

echo "@@@ Done"

