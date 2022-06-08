# GenOnHPC: Generator configurations on High Performance Computing Resource
이 프로젝트는 nurion HPC시스템 위에서 여러 MC generator들을 이용해 대용량 MC샘플을 생성하기 위한 환경 세팅, 잡 섭밋 환경 등을 다룹니다.
각종 MC generator에 따라 달라지는 라이브러리 세팅 등의 문제를 피하기 위하여 singularity container를 이용하고, 따라서 singularity recipe도 함께 제공합니다.

LHC에서는 gridpack라는 잘 검증된 시스템이 있지만, 여기에서는 별도의 환경을 구축합니다. Gridpack은 잘 검증되어 있지만, nurion시스템에서는 그리드, cvmfs, condor cmssw등과 의존성이 있는 경우 이를 구성하기 어려울 수 있기 때문입니다.

### 현재(2022.06.08)까지  사용해본 MC Generator list
Powheg : <https://powhegbox.mib.infn.it/>    
MG5 : <https://launchpad.net/mg5amcnlo>    
Pythia8 : <https://pythia.org/>    
Herwig7 : <https://herwig.hepforge.org/index.html>    
Sherpa : <https://sherpa-team.gitlab.io/>    


## Building singularity images
Singularity image를 만들기 위한 recipe파일들은 `config/singularity`디렉토리 아래에 저장되어 있습니다.

Example
```
cd config/singularity
singularity build mg5_amc_2.9.9.sif mg5_amc_2.9.recipe
```

---
Singularity image를 만들기 위해 사용한 docker image는 hepstore의 docker image들을 사용하였습니다.
<https://hub.docker.com/u/hepstore>


## Producing MC samples

Example command to produce 1M events:
```
cd test/mg5
export SIF=../../config/singularity/mg5_amc_2.9.9.sif
export LHAPDFSETS=/store/sw/hep/lhapdfsets/current
export NCPUS=8
export JOBSTART=1000
export NEVENT=10000
export NJOBS=100
export JOBSUFFIX="1M"
export DORUN=1
./prepare.sh TTTT_5f_NLO.tgz
```

## Wrting MC cards
MC generator들을 활용하려면 먼저 각각 제너레이터에 필요한 Card들을 작성해야합니다. 




### CMS card link
Powheg : <https://github.com/cms-sw/genproductions/tree/master/bin/Powheg>    
MG5 : <https://github.com/cms-sw/genproductions/tree/master/bin/MadGraph5_aMCatNLO>    
Pythia8 : <https://github.com/cms-sw/cmssw/tree/master/Configuration/Generator/python>    
Herwig7 : <https://github.com/cms-sw/cmssw/tree/master/Configuration/Generator/python/Herwig7Settings>    
Sherpa : <https://github.com/cms-sw/genproductions/tree/master/bin/Sherpa>    


 
## MC 샘플을 validate 하기 위해서 rivet toolkit을 사용하게됩니다.



