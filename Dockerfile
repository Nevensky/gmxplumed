# Start from cuda-10-devel ubuntu
FROM nvidia/cuda:10.0-devel
 
LABEL maintainer="Neven Golenic <neven.golenic@gmail.com>"

# disable apt-get questions
ARG DEBIAN_FRONTEND=noninteractive
# installation dir
ARG work=/tmp
WORKDIR $work

# apt-get dependencies variables, ref by $varname
ARG plumed_buildDeps="git"
ARG plumed_runtimeDeps="gawk libopenblas-base libgomp1 make openssh-client openmpi-bin vim zlib1g git g++ libopenblas-dev libopenmpi-dev libmatheval-dev xxd zlib1g-dev"
#ARG cuda_buildDeps="cuda-compiler-10-0"
ARG gromacs_buildDeps="cmake"
ARG gromacs_runtimeDeps="libfftw3-dev hwloc python"

# install libraries 
RUN apt-get -yq update \
 && apt-get -yq install --no-install-recommends $plumed_buildDeps $gromacs_buildDeps $plumed_runtimeDeps $gromacs_runtimeDeps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# clone plumed into workdir
RUN git clone --branch "v2.5.2" https://github.com/plumed/plumed2.git

# compile plumed
WORKDIR $work/plumed2
RUN ./configure --prefix="/usr/local/plumed" --enable-modules="all"  CXX="mpicxx" CXXFLAGS="-O3" \
 && make -j "$(nproc)" \
 && make install \
 && rm -rf ../plumed2

# set plumed env vars
ENV PATH="/usr/local/plumed/bin:${PATH}"
ENV PLUMED_KERNEL="/usr/local/plumed/lib/libplumedKernel.so"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/plumed/lib/"

# return to workdir and clone gromacs
WORKDIR $work
RUN git clone --branch "v2019.1" https://github.com/gromacs/gromacs.git

# patch gromacs with plumed and compile
WORKDIR $work/gromacs
RUN plumed patch -p --runtime -e "gromacs-2019.1" \
 && mkdir -p build
WORKDIR $work/gromacs/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX="/usr/local/gromacs" -DGMX_SIMD="AVX2_256" -DGMX_BUILD_OWN_FFTW="off" -DGMX_GPU="on" -DGMX_USE_NVML="off" \
 && make -j "$(nproc)" \
 && make install \
 && rm -rf ../../gromacs

#MPI cmake (if needed): -DGMX_MPI=on -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx

# export gromacs binary to path
ENV PATH="/usr/local/gromacs/bin:${PATH}"

# remove build packages and fix possibly broken runtime packages
RUN apt-get purge -y --auto-remove $plumed_buildDeps $gromacs_buildDeps \
 && apt-get update && apt-get -yq install --no-install-recommends $plumed_runtimeDeps $gromacs_runtimeDeps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# switch to plumgrompy user
RUN ["useradd","-ms","/bin/bash","gmxplumed"]
USER gmxplumed
WORKDIR $work

# source gromacs env vars
RUN /bin/bash -c "source /usr/local/gromacs/bin/GMXRC.bash"

# print gromacs and plumed versions and enter bash shell
CMD gmx --version \
  && echo "Plumed version: $(plumed info --long-version)" \
  && bash

