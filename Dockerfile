FROM ubuntu:18.04

ARG BACKEND=HIP
ARG ROCMVERSION=3.7
ARG OSDB_BKC_VERSION=0
ARG REPO_DIR=compute-rocm-dkms-no-npi-hipclang

RUN set -xe

ARG DEB_ROCM_REPO=http://repo.radeon.com/rocm/apt/.apt_$ROCMVERSION/
RUN apt update && apt install -y wget software-properties-common 

# Add rocm repository
RUN apt-get clean all
RUN wget -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | apt-key add -

RUN if [ $OSDB_BKC_VERSION -ne 0 ]; then \
       echo "Using BKC VERISION: $OSDB_BKC_VERSION"; \
       sh -c "echo deb [arch=amd64 trusted=yes] http://compute-artifactory.amd.com/artifactory/list/rocm-osdb-deb/ ${REPO_DIR} ${OSDB_BKC_VERSION}  > /etc/apt/sources.list.d/rocm.list" ;\
       cat  /etc/apt/sources.list.d/rocm.list; \
    else \
       sh -c "echo deb [arch=amd64] $DEB_ROCM_REPO xenial main > /etc/apt/sources.list.d/rocm.list" ;\
    fi


# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated \
    apt-utils \
    build-essential \
    cmake \
    cmake-curses-gui \
    curl \
    doxygen \
    g++ \
    gdb \
    git \
    hip-rocclr \
    lcov \
    libelf-dev \
    libncurses5-dev \
    libnuma-dev \
    libpthread-stubs0-dev \
    miopengemm \
    pkg-config \
    python \
    python3 \
    python-dev \
    python3-dev \
    python-pip \
    python3-pip \
    software-properties-common \
    wget \
    rocm-dev \
    rocm-opencl \
    rocm-opencl-dev \
    rocm-cmake \
    rocblas \
    vim \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN wget http://compute-artifactory.amd.com/artifactory/list/rocm-osdb-deb/compute-rocm-dkms-staging-82/llvm-amdgpu-12.0.dev-amd64.deb
RUN wget http://compute-artifactory.amd.com/artifactory/list/rocm-osdb-deb/compute-rocm-dkms-staging-82/rocm-device-libs-1.0.0.637-rocm-dkms-staging-82-d66378e-Linux.deb
RUN dpkg -i llvm-amdgpu-12.0.dev-amd64.deb
RUN dpkg -i rocm-device-libs-1.0.0.637-rocm-dkms-staging-82-d66378e-Linux.deb


#SET MIOPEN ENVIRONMENT VARIABLES
ENV PATH=$PREFIX/miopen/bin:$PREFIX/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/rocm/lib:$LD_LIRBARY_PATH
ENV DEVICE_LIB_PATH=/opt/rocm-3.9.0-82/amdgcn/bitcode
ENV HIP_CLANG_PATH=/opt/rocm-3.9.0-82/llvm/bin
ENV HSA_FORCE_ASIC_TYPE="10.3.0 Sienna_Cichlid 18"
ENV CXX=/opt/rocm-3.9.0-82/llvm/bin/clang++
ENV CC=/opt/rocm-3.9.0-82/llvm/bin/clang
RUN alias ll="ls -al"
RUN ulimit -c unlimited


#SET MIOPEN ENVIRONMENT VARIABLES
RUN apt update && apt install -y kmod
RUN apt update && apt install -y mysql-client
RUN apt update && apt install -y ssh 

