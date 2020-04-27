FROM ubuntu:16.04

ARG TUNA_USER=miopenpdb
ARG PREFIX=/opt/rocm
ARG MIOPEN_SRC=./MIOpen
ARG MIOPEN_DIR=/root/dMIOpen
ARG MIOPEN_BRANCH=develop
ARG MIOPEN_DEPS=$PREFIX/miopendeps
ARG BACKEND=HIP
ARG ROCMVERSION=3.3
ARG OSDB_BKC_VERSION=0

RUN set -xe
RUN mkdir -p $MIOPEN_DIR

ARG DEB_ROCM_REPO=http://repo.radeon.com/rocm/apt/.apt_$ROCMVERSION/
RUN apt update && apt install -y wget software-properties-common 

# Add rocm repository
RUN apt-get clean all
RUN wget -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | apt-key add -

RUN if [ $OSDB_BKC_VERSION -ne 0 ]; then \
       echo "Using BKC VERISION: $OSDB_BKC_VERSION"; \
       sh -c "echo deb [arch=amd64 trusted=yes] http://compute-artifactory.amd.com/artifactory/list/rocm-osdb-deb/ compute-rocm-dkms-no-npi ${OSDB_BKC_VERSION}  > /etc/apt/sources.list.d/rocm.list" ;\
       cat  /etc/apt/sources.list.d/rocm.list; \
    else \
       sh -c "echo deb [arch=amd64] $DEB_ROCM_REPO xenial main > /etc/apt/sources.list.d/rocm.list" ;\
    fi


RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated \
    apt-utils \
    build-essential \
    clang-3.8 \
    cmake \
    curl \
    g++-multilib \
    git \
    hsa-rocr-dev \
    hsakmt-roct-dev \
    lcov \
    libelf-dev \
    libncurses5-dev \
    libpthread-stubs0-dev \
    libnuma-dev \
    libunwind-dev \
    nsis \
    python \
    python-dev \
    python-pip \
    rocm-clang-ocl \
    rocm-opencl \
    rocm-opencl-dev \
    rocm-smi \
    miopengemm \
    hcc \
    hip-hcc \
    rocblas \
    software-properties-common \
    wget \
    vim \
    htop \
    openssh-server \
    rocm-cmake \
    pkg-config \
    comgr \
    xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup ubsan environment to printstacktrace
RUN ln -s /usr/bin/llvm-symbolizer-3.8 /usr/local/bin/llvm-symbolizer
ENV UBSAN_OPTIONS=print_stacktrace=1

# Install an init system
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
RUN dpkg -i dumb-init_*.deb && rm dumb-init_*.deb

# Install cget
RUN pip install cget

# Install rclone
RUN pip install https://github.com/pfultz2/rclone/archive/master.tar.gz

#Copy In MIOpen
ADD $MIOPEN_SRC $MIOPEN_DIR
WORKDIR $MIOPEN_DIR

# Install dependencies
RUN cmake -P install_deps.cmake --minimum --prefix $MIOPEN_DEPS

# Build MIOpen
WORKDIR $MIOPEN_DIR/build
RUN git checkout $MIOPEN_BRANCH
RUN echo "MIOPEN: Selected $BACKEND backend."
RUN if [ $BACKEND = "OpenCL" ]; then \
           cmake -DMIOPEN_CACHE_DIR=/home/$TUNA_USER/.cache -DMIOPEN_USER_DB_PATH=/home/$TUNA_USER/.config/miopen -DMIOPEN_BACKEND=OpenCL -DCMAKE_PREFIX_PATH="$MIOPEN_DEPS" $MIOPEN_DIR ; \
    else \
           CXX=/opt/rocm/hcc/bin/hcc cmake -DMIOPEN_CACHE_DIR=/home/$TUNA_USER/.cache -DMIOPEN_USER_DB_PATH=/home/$TUNA_USER/.config/miopen -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/hcc;/opt/rocm/hip;$MIOPEN_DEPS" $MIOPEN_DIR ; \
    fi

RUN make -j
RUN make install


#SET MIOPEN ENVIRONMENT VARIABLES
ENV MIOPEN_LOG_LEVEL=6
ENV PATH=$PREFIX/miopen/bin:$PREFIX/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/rocm/lib:$LD_LIRBARY_PATH
RUN alias ll="ls -al"
RUN ulimit -c unlimited



