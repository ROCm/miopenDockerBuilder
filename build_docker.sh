#!/bin/bash

USEAGE="Usage: ./build_docker.sh -d <docker_image_name> -b <miopen_branch> -s <miopen_src_dir> -p"


if [ $# -lt 1 ]; then
  echo "Error At least one arguments required." 
  echo ${USEAGE}
  echo
  exit 1
fi

DOCKNAME="miopen_build"
BRANCHNAME="master"
BRANCHURL="https://github.com/ROCmSoftwarePlatform/MIOpen.git"
SRCPATH=""
USEPUBLIC=1
SRCPATH="./MIOpen"


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -d|--dockername)
    DOCKNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--miopenbranch)
    BRANCHNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--sourcepath)
    SRCPATH="./$2"
    shift # past argument
    shift # past value
    ;;
    -p| --private)
    USEPUBLIC=0
    shift # past argument
    ;;
    -h|--help)
    echo ${USEAGE}
    echo
    exit 0
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


#Clone MIOpen
if [ ${USEPUBLIC} -eq 0 ]; then
	echo "**Using private MIOpen GitHub repo."
	BRANCHURL="https://github.com/AMDComputeLibraries/MLOpen.git"
else
	echo "**Using public MIOpen GitHub repo."
fi

if [ ! -d "$SRCPATH" ]; then
	git clone --branch ${BRANCHNAME} ${BRANCHURL} ${SRCPATH}
else
	echo "Folder ${SRCPATH} already exists."
fi


#build the docker
docker build -t ${DOCKNAME} --build-arg MIOPEN_BRANCH=${BRANCHNAME} --build-arg MIOPEN_SRC=${SRCPATH} .


