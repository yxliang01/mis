FROM ubuntu:16.04 as builder

LABEL maintainer="Mate Soos"
LABEL version="1.0"
LABEL Description="MIS"

# get curl, etc
RUN apt-get update
RUN apt-get install --no-install-recommends -y software-properties-common
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install --no-install-recommends -y make g++
RUN apt-get install --no-install-recommends -y zlib1g-dev git libboost-dev
RUN apt-get install --no-install-recommends -y git

# build mis
USER root
COPY . /mis
WORKDIR /mis
RUN git clone https://bitbucket.org/anton_belov/muser2 muser2-dir
RUN make

# set up for running
FROM ubuntu:16.04
RUN adduser mis
RUN apt-get update && apt-get install --no-install-recommends -y python3 \
    && rm -rf /var/lib/apt/lists/*
USER mis
COPY --from=builder /mis/mis.py /usr/local/bin/
COPY --from=builder /mis/muser2 /usr/local/bin/
COPY --from=builder /mis/togmus /usr/local/bin/
WORKDIR /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/mis.py"]

# --------------------
# HOW TO USE
# --------------------
# NOTE: You should put the input under /home/mis or directory that normal user has read/write permissions of
#    docker run --rm -v `pwd`/formula.cnf:/home/mis/in msoos/mis /home/mis/in
