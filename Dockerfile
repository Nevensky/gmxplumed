# Start from cuda-10-devel ubuntu
FROM nvidia/cuda:10.0-devel

# disable apt-get questions
ARG DEBIAN_FRONTEND=noninteractive 


MAINTAINER Neven Golenic <neven.golenic@gmail.com>

# installation dir
ARG work=/tmp
WORKDIR $work

# apt-get dependencies variables, ref by $varname
ARG plumed_buildDeps="git"
ARG plumed_runtimeDeps="gawk libopenblas-base libgomp1 make openssh-client openmpi-bin vim zlib1g git g++ libopenblas-dev libopenmpi-dev xxd zlib1g-dev"
#ARG cuda_buildDeps="cuda-compiler-10-0"
ARG gromacs_buildDeps="cmake"
ARG gromacs_runtimeDeps="libfftw3-dev hwloc python"

# install libraries 
RUN apt-get -yq update \
 && apt-get -yq upgrade \
 && apt-get -yq install $plumed_buildDeps $gromacs_buildDeps $plumed_runtimeDeps $gromacs_runtimeDeps --no-install-recommends

# clone plumed into workdir
RUN git clone --branch v2.4.4 git://github.com/plumed/plumed2.git

# compile plumed
RUN cd plumed2 \
 && ./configure --enable-modules=all CXXFLAGS=-O3 \
 && make -j$(nproc) \
 && make install \
 && cd ../ \
 && rm -rf plumed2

# return to workdir and clone gromacs
WORKDIR $work
RUN git clone --branch v2018.4 https://github.com/gromacs/gromacs.git

# patch gromacs with plumed and compile
RUN cd gromacs \
 && plumed patch -p --runtime -e gromacs-2018.4 \
# && apt-get update && apt-get -yq install $gromacs_buildDeps $gromacs_runtimeDeps --no-install-recommends \
 && mkdir build \
 && cd build \
 && cmake .. -DGMX_SIMD=AVX_256 -DGMX_BUILD_OWN_FFTW=off -DGMX_GPU=on -DCMAKE_INSTALL_PREFIX=/usr/local/gromacs \
 && make -j$(nproc) \
 && make install \
 && apt-get purge -y --auto-remove $plumed_buildDeps $gromacs_buildDeps \
 && apt-get update && apt-get -yq install $plumed_runtimeDeps $gromacs_runtimeDeps --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/local/gromacs:${PATH}"

#MPI cmake (if needed): DGMX_MPI=on -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx


# switch to plumgrompy-gpu user
RUN useradd -ms /bin/bash plumgrompy-gpu
USER plumgrompy-gpu
WORKDIR $work
# by default enter bash
CMD ["bash"]

