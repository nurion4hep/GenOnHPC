# GenOnHPC: Generator configurations on High Performance Computing Resource
이 프로젝트는 nurion HPC시스템 위에서 여러 MC generator들을 이용해 대용량 MC샘플을 생성하기 위한 환경 세팅, 잡 섭밋 환경 등을 다룹니다.
각종 MC generator에 따라 달라지는 라이브러리 세팅 등의 문제를 피하기 위하여 singularity container를 이용하고, 따라서 singularity recipe도 함께 제공합니다.

LHC에서는 gridpack라는 잘 검증된 시스템이 있지만, 여기에서는 별도의 환경을 구축합니다. Gridpack은 잘 검증되어 있지만, nurion시스템에서는 그리드, cvmfs, condor cmssw등과 의존성이 있는 경우 이를 구성하기 어려울 수 있기 때문입니다.

## Building singularity images

## Producing MC samples

Example command to produce 10M events:
```
export SIF=/store/sw/singularity/mg5/mg5_amc_2.9.9.sif
export LHAPDFSETS=/store/sw/hep/lhapdfsets/current
export NCPUS=8
export JOBSTART=1000
export NEVENT=10000
export NJOBS=100
export JOBSUFFIX="10M"
export DORUN=1
./prepare.sh TTTT_5f_NLO.tgz
```
