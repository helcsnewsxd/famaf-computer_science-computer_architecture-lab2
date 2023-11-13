#!/bin/bash

CONTAINER_NAME="adc_gem5"
IMAGE_NAME="gvodanovic/adc_gem5:latest"
RESULT_PATH="se_results"


# Definir el benchmark a correr, opciones: daxpy, simFisica, bubbleSort
if [ -z $BENCHMARK ]; then
    BENCHMARK="daxpy"
fi

# Definir el procesador a utilizar, opciones: in_order, out_of_order, etc.
if [ -z $PROCESSOR ]; then
    PROCESSOR="in_order"
fi

docker run -it --rm -v $(pwd):/local --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -v "$HOME/.Xauthority:/root/.Xauthority:rw" --name $CONTAINER_NAME $IMAGE_NAME /bin/bash -c "aarch64-linux-gnu-gcc --static /local/benchmarks/$BENCHMARK.s -o /local/benchmarks/$BENCHMARK.img -I /opt/gem5/include -L /opt/gem5/util/m5/build/arm64/out/ -lm5 /opt/gem5/util/m5/build/arm64/out/libm5.a"

docker run -it --rm -v $(pwd):/local --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -v "$HOME/.Xauthority:/root/.Xauthority:rw" --name $CONTAINER_NAME $IMAGE_NAME /bin/bash -c "/opt/gem5/build/ARM/gem5.opt -d $RESULT_PATH /local/scripts/se.py /local/scripts/cpu_config.toml $PROCESSOR /local/benchmarks/$BENCHMARK.img" > sim.log

python3 scripts/stat-collect.py se_results/stats.txt
