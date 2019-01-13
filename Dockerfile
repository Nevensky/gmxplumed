# Start from latest ubuntu
FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive

# this is home for root user
WORKDIR /tmp

# install libraries and plumed
RUN buildDeps="git" \
 && runtimeDeps="gawk libopenblas-base libgomp1 make openssh-client openmpi-bin vim zlib1g git g++ libopenblas-dev libopenmpi-dev xxd zlib1g-dev" \
 && apt-get -yq update \
 && apt-get -yq upgrade \
 && apt -yq install $buildDeps $runtimeDeps --no-install-recommends

# clones plumed into
RUN git clone --branch v2.4.4 git://github.com/plumed/plumed2.git

RUN cd plumed2 \
 && ./configure --enable-modules=all CXXFLAGS=-O3 \
 && make -j 4 \
 && make install \
 && cd ../ \
 && rm -fr plumed2 \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt -yq install $runtimeDeps --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*
# switch to plumed user
RUN useradd -ms /bin/bash plumed
USER plumed
WORKDIR /home/plumed
# by default enter bashs
CMD /bin/bash


