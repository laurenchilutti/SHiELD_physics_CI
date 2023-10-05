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
if [ -z "$1" ]
  then
    echo "No branch supplied; using main"
    branch=main
  else
    echo Branch is ${1}
    branch=${1}
fi
testDir=${dirRoot}/${intelVersion}/SHiELD_physics/${branch}
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
