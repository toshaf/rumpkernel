FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y git
RUN git clone http://repo.rumpkernel.org/rumprun /src/rumprun
RUN cd /src/rumprun; git submodule update --init
RUN apt-get install -y make
RUN apt-get install -y g++
RUN apt-get install -y zlib1g-dev
RUN cd /src/rumprun; CC=cc ./build-rr.sh hw 
RUN apt-get install -y tree
ENV PATH=/src/rumprun/rumprun/bin:$PATH
