#!/bin/bash
set -e

USAGE="Usage: ./build_docker.sh -d <docker_image_name> -b <miopen_branch> -s <miopen_src_dir> -v <rocm-version> --bkc <bkc-version-number> --private --opencl --no-cache"


if [ $# -lt 1 ]; then
  echo "Error At least one arguments required." 
  echo ${USAGE}
  echo
  exit 1
fi

DOCKNAME="miopentuna"
BRANCHNAME="develop"
BRANCHURL="https://github.com/ROCmSoftwarePlatform/MIOpen.git"
SRCPATH=""
USEPRIVATE=0
SRCPATH="./MIOpen"
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
    -v|--rocmversion)
    ROCMVERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -p| --private)
    USEPRIVATE=1
    shift # past argument
    ;;
    -o| --opencl)
    BACKEND="OpenCL"
    shift # past argument
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
    echo "(-b / --miopenbranch) the branch of miopen to be used"
    echo "(-s / --sourcepath) location of the miopen source directory to be imported into the Docker"
    echo "(-v / --rocmversion) version of ROCm to tune with"
    echo "(-k / --bkc) OSDB BKC version to use (NOTE: non-zero value here will override ROCm version flag --rocmversion)"
    echo "(-p / --private) Use MIOpen private repo if needed, DEPRECATED"
    echo "(-o / --opencl) Use OpenCL backend over HIP version"
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


#Clone MIOpen
if [ ${USEPRIVATE} -eq 1 ]; then
	echo "**Using private MIOpen GitHub repo."
	BRANCHURL="https://github.com/AMDComputeLibraries/MLOpen.git"
else
	echo "**Using public MIOpen GitHub repo."
fi

if [ ! -d "$SRCPATH" ]; then
	git clone --branch ${BRANCHNAME} ${BRANCHURL} ${SRCPATH}
else
	echo "WARNING: Folder ${SRCPATH} already exists."
fi



#build the docker
docker build -t ${DOCKNAME} ${NC} --build-arg OSDB_BKC_VERSION=${BKC_VERSION} --build-arg MIOPEN_BRANCH=${BRANCHNAME} --build-arg MIOPEN_SRC=${SRCPATH} --build-arg BACKEND=${BACKEND} --build-arg ROCMVERSION=${ROCMVERSION} .


