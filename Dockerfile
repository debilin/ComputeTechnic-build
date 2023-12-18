FROM debian:11

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  git \
  build-essential \
  cmake \
  python3 \
  googletest \
  libgtest-dev \
  libeigen3-dev \
  libz-dev


WORKDIR /
ADD ComputeTechnic /ComputeTechnic

RUN cd /ComputeTechnic && cmake -B build -S . && cmake --build build


CMD ["/bin/sh", "-c", "bash"]