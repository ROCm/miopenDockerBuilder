#!/bin/bash
set -e

USAGE="Usage: ./build_docker.sh -d <docker_image_name> -v <rocm-version> --bkc <bkc-version-number> --no-cache"


if [ $# -lt 1 ]; then
  echo "Error At least one arguments required." 
  echo ${USAGE}
  echo
  exit 1
fi

DOCKNAME="miopen-mixedbag"
BRANCHNAME="develop"
BRANCHURL="https://github.com/ROCmSoftwarePlatform/MIOpen.git"
BACKEND="HIP"
ROCMVERSION="0"
BKC_VERSION=0
NC=""

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
    -v|--rocmversion)
    ROCMVERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -k| --bkc)
    BKC_VERSION=$2 #overrides rocmversion
    echo "BKC Version selected: $BKC_VERSION"
    shift # past argument
    ;;
    -n| --no-cache)
    NC="--no-cache"
    shift # past argument
    ;;
    -h|--help)
    echo ${USAGE}
    echo "(-d / --dockername) the name of the docker"
    echo "(-v / --rocmversion) version of ROCm to tune with"
    echo "(-k / --bkc) OSDB BKC version to use (NOTE: non-zero value here will override ROCm version flag --rocmversion)"
    echo "(-n / --no-cache) Build the docker from scratch"
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

if [[ "${ROCMVERSION}" == "0" && ${BKC_VERSION} -eq 0 ]]; then
       echo "Either the ROCm version, or the BKC version must be specified."
       echo $USAGE
       exit 1
fi



#build the docker
docker build -t ${DOCKNAME} ${NC} --build-arg OSDB_BKC_VERSION=${BKC_VERSION} --build-arg ROCMVERSION=${ROCMVERSION} .


