# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang

## Add source code to the build stage.
ADD . /pforth
WORKDIR /pforth

## TODO: ADD YOUR BUILD INSTRUCTIONS HERE.
#RUN mkdir build && cd build/
# /mayhem-cmake-example
#RUN mkdir
#WORKDIR build
#RUN CC=clang CXX=clang++ cmake ..
#RUN make
WORKDIR platforms/unix
RUN make all

# Package Stage
FROM --platform=linux/amd64 ubuntu:20.04

## TODO: Change <Path in Builder Stage>
COPY --from=builder /pforth /

