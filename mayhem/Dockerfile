FROM --platform=linux/amd64 ubuntu:20.04 as builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang

ADD . /pforth
WORKDIR /pforth

WORKDIR platforms/unix
RUN make all

FROM --platform=linux/amd64 ubuntu:20.04

COPY --from=builder /pforth /
