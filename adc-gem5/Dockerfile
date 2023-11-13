FROM ubuntu:20.04

# install app dependencies
RUN apt-get update && apt-get install -y python3 python3-pip
RUN apt-get install -y wget git gcc g++ build-essential
RUN apt-get install -y python-dev m4 swig protobuf-compiler 
RUN apt-get install -y libgoogle-perftools-dev vim scons zip
RUN apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
RUN apt-get install -y libpng-dev libhdf5-dev

# Install gem5
RUN wget https://raw.githubusercontent.com/arm-university/arm-gem5-rsk/master/clone.sh -P /opt/
WORKDIR "/opt"
RUN bash clone.sh
WORKDIR "/opt/gem5" 
RUN scons build/ARM/gem5.opt -j4 # parallel build
RUN rm /opt/clone.sh
WORKDIR "/opt"
RUN git clone https://github.com/gem5/gem5-resources
WORKDIR "/opt/gem5-resources/src/simple" 
RUN make ISA=aarch64 all
WORKDIR "/opt/gem5"
RUN scons -C util/m5/build/arm64/out/m5

RUN pip install toml

# Change to home directory
WORKDIR "/local/"
