#!/bin/sh -xe

##############################################################################
## User set up variables
## Root directory for CI
dirRoot=/contrib/fv3
## Intel version to be used
intelVersion=2023.2.0
##############################################################################
## HPC-ME container
container=/contrib/containers/noaa-intel-prototype_2023.09.25.sif
container_env_script=/contrib/containers/load_spack_noaa-intel.sh
##############################################################################
## Set up the directories
# First argument should be $GITHUB_REF which is the reference to the PR/branch
# to be checked out for SHiELD_physics
if [ -z "$1" ]
  then
    echo "No branch/PR supplied; using main"
    branch=main
  else
    echo Branch is ${1}
    branch=${1}
fi
# Second Argument should be $GITHUB_SHA whcih  is the commit hash of the
# branch or PR to trigger the CI, if run manually, you do not need a 2nd
# argument.  This is needed in the circumstance where a PR is created, 
# then the CI triggers, and before that CI has finished, the developer
# pushes a newer commit which triggers a second round of CI.  We would
# like unique directories so that both CI runs do not interfere.
if [ -z "$2" ]
  then
    echo "No second argument"
    commit=none
  else
    echo Commit is ${2}
    commit=${2}
fi

testDir=${dirRoot}/${intelVersion}/SHiELD_physics/${branch}/${commit}
logDir=${testDir}/log
export MODULESHOME=/usr/share/lmod/lmod
## create directories
rm -rf ${testDir}
mkdir -p ${logDir}
# salloc commands to start up 
#2 tests layout 8,8 (16 nodes)
#2 tests layout 4,8 (8 nodes)
#9 tests layout 4,4 (18 nodes)
#5 tests layout 4,1 (5 nodes)
#17 tests layout 2,2 (17 nodes)
#salloc --partition=p2 -N 64 -J ${branch} sleep 20m &

## clone code
cd ${testDir}
git clone --recursive https://github.com/NOAA-GFDL/SHiELD_build.git && cd SHiELD_build && ./CHECKOUT_code
## Check out the PR
cd ${testDir}/SHiELD_SRC/SHiELD_physics && git fetch origin ${branch}:toMerge && git merge toMerge
