FROM ubuntu:16.04

ARG PREFIX=/opt/rocm
ARG MIOPEN_SRC=./MLOpen
ARG MIOPEN_DIR=/MIOpen
ARG MIOPEN_BRANCH=develop
ARG MIOPEN_DEPS=$PREFIX/miopendeps
ARG BACKEND=HIP

RUN mkdir -p $MIOPEN_DIR
ADD $MIOPEN_SRC $MIOPEN_DIR

# Add rocm repository
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl apt-utils wget
RUN curl https://raw.githubusercontent.com/RadeonOpenCompute/ROCm-docker/master/add-rocm.sh | bash

ADD rocblas-2.2.11.3-Linux.deb /

# Install dependencies required to build hcc
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated \
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
    miopengemm \
    libboost-all-dev \
    hcc \
    hip_hcc \
    software-properties-common \
    wget \
    vim \
    htop \
    openssh-server \
    cmake-curses-gui \
    xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# Install rocblas
RUN dpkg -i rocblas-2.2.11.3-Linux.deb


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
WORKDIR $MIOPEN_DIR

# Bypass unneeded dependencies
RUN cget -p $PREFIX init --cxx $PREFIX/bin/hcc --std=c++14
RUN cget -p $PREFIX ignore RadeonOpenCompute/clang-ocl
RUN cget -p $PREFIX ignore ROCmSoftwarePlatform/MIOpenGEMM
RUN cget -p $PREFIX ignore ROCmSoftwarePlatform/rocBLAS
RUN cget -p $PREFIX ignore boost

# Install dependencies
RUN CXXFLAGS='-isystem $PREFIX/include' cget -p $PREFIX install -f ./requirements.txt

# Build MIOpen
WORKDIR $MIOPEN_DIR/build
RUN git checkout $MIOPEN_BRANCH
RUN echo "MIOPEN: Selected $BACKEND backend."
RUN if [ "$BACKEND" = "OpenCL" ]; then \
           cmake -DMIOPEN_BACKEND=OpenCL -DMIOPEN_TEST_ALL=On -DBoost_USE_STATIC_LIBS=Off -DCMAKE_PREFIX_PATH="$MIOPEN_DEPS" $MIOPEN_DIR ; \
    else \
           CXX=/opt/rocm/hcc/bin/hcc cmake -DMIOPEN_BACKEND=HIP -DMIOPEN_TEST_ALL=On -DBoost_USE_STATIC_LIBS=Off -DCMAKE_PREFIX_PATH="/opt/rocm/hcc;/opt/rocm/hip;$MIOPEN_DEPS" $MIOPEN_DIR ; \
    fi

RUN make -j MIOpenDriver
RUN make -j tests
RUN make install



#SET MIOPEN ENVIRONMENT VARIABLES
ENV PATH=$PREFIX/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/rocm/lib:$LD_LIRBARY_PATH
RUN alias ll="ls -al"




