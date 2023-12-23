FROM debian:11

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  git \
  build-essential \
  cmake \
  python3 \
  googletest \
  libgtest-dev \
  libeigen3-dev \
  libz-dev \
  python3-matplotlib \
  python3-numpy \
  python3-pip \
  patchelf

WORKDIR /
ADD ComputeTechnic /ComputeTechnic
RUN mkdir -p /ComputeTechnic/LEGO_Technic_data/1_debug
RUN cd /ComputeTechnic && cmake -B build -S . && cmake --build build
RUN rm -rf /ComputeTechnic/lib/
RUN rm -rf /ComputeTechnic/lego_technic_test/lib/

ADD matplotlibrc /matplotlibrc
ADD hooks.py /hooks.py
RUN pip install pyinstaller staticx patchelf-wrapper
RUN cd /ComputeTechnic/python/ && \
    pyinstaller --clean --noconsole --runtime-hook /hooks.py --add-data /matplotlibrc:. --onefile lego_vis_edges.py && \
    staticx dist/lego_vis_edges ../build/lego_vis_edges

WORKDIR /lego

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
#CMD ["/bin/sh", "-c", "bash"]