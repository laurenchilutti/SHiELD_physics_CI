#!/bin/bash -xe
ulimit -s unlimited
##############################################################################
## User set up veriables
## Root directory for CI
dirRoot=/contrib/fv3
## Intel version to be used
intelVersion=2023.2.0
##############################################################################
## HPC-ME container
container=/contrib/containers/noaa-intel-prototype_2023.09.25.sif
container_env_script=/contrib/containers/load_spack_noaa-intel.sh
## Set up the directories
if [ -z "$1" ]
  then
    echo "No branch supplied; using main"
    branch=main
  else
    echo Branch is ${1}
    branch=${1}
fi
if [ -z "$2" ]
  then
    echo "No second argument"
    commit=none
  else
    echo Commit is ${2}
    commit=${2}
fi
MODULESHOME=/usr/share/lmod/lmod
testDir=${dirRoot}/${intelVersion}/SHiELD_physics/${branch}/${commit}
logDir=${testDir}/log
baselineDir=${dirRoot}/baselines/intel/${intelVersion}
## Run the CI Test
# Define the builddir testscriptdir and rundir BUILDDIR is used by test scripts 
# Set the BUILDDIR for the test script to use
export BUILDDIR="${testDir}/SHiELD_build"
testscriptDir=${BUILDDIR}/RTS/CI
runDir=${BUILDDIR}/CI/BATCH-CI

# Run CI test scripts
cd ${testscriptDir}
set -o pipefail
# Define the test
test=C96.solo.mtn_rest
# Execute the test piping output to log file
./${test} " --partition=p2 --mpi=pmi2 --job-name=${commit}_${test} singularity exec -B /contrib ${container} ${container_env_script}" |& tee ${logDir}/run_${test}.log

## Compare Restarts to Baseline
source $MODULESHOME/init/sh
export MODULEPATH=/mnt/shared/manual_modules:/usr/share/modulefiles/Linux:/usr/share/modulefiles/Core:/usr/share/lmod/lmod/modulefiles/Core:/apps/modules/modulefiles:/apps/modules/modulefamilies/intel
module load intel/2022.1.2
module load netcdf
module load nccmp
for resFile in `ls ${baselineDir}/${test}`
do
  nccmp -d ${baselineDir}/${test}/${resFile} ${runDir}/${test}/RESTART/${resFile}
done
