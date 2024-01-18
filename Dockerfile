FROM debian:11 AS builder

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
  patchelf \
  binutils \
  squashfs-tools \
  ruby

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

RUN gem install fpm && fpm --version

WORKDIR /dist
ADD lego-technic.sh /lego-technic.sh
ADD afterinstall.sh /afterinstall.sh

RUN nightly=$(date +"%Y.%m.%d") && \
    fpm \
    -s dir -t deb \
    -p lego-technic-nightly-$nightly-amd64.deb \
    --name lego-technic-nightly \
    --license agpl3 \
    --version $nightly \
    --architecture amd64 \
    --depends bash --depends podman --depends ldraw-parts \
    --description "We introduce a method to automatically compute LEGO Technic models from user input sketches, optionally with motion annotations. The generated models resemble the input sketches with coherently-connected bricks and simple layouts, while respecting the intended symmetry and mechanical properties expressed in the inputs. This complex computational assembly problem involves an immense search space, and a much richer brick set and connection mechanisms than regular LEGO. To address it, we first comprehensively model the brick properties and connection mechanisms, then formulate the construction requirements into an objective function, accounting for faithfulness to input sketch, model simplicity, and structural integrity. Next, we model the problem as a sketch cover, where we iteratively refine a random initial layout to cover the input sketch, while guided by the objective. At last, we provide a working system to analyze the balance, stress, and assemblability of the generated model. To evaluate our method, we compared it with four baselines and professional designs by a LEGO expert, demonstrating the superiority of our automatic designs. Also, we recruited several users to try our system, employed it to create models of varying forms and complexities, and physically built most of them." \
    --url "" \
    --maintainer "brainiac <0xD4F149A22CFc747fF1004C79917edc4C754Efa34@hashmail.dev>" \
    --after-install /afterinstall.sh \
      /ComputeTechnic/build/lego_vis_edges=/usr/local/bin/lego_vis_edges \
      /lego-technic.sh=/usr/local/bin/lego-technic \
      /ComputeTechnic/LEGO_Technic_data/3_tools/my_ldraw/joints/=/usr/share/lego-technic/joints/

CMD ["/bin/sh", "-c", "bash"]

FROM debian:11 AS release

COPY --from=builder /ComputeTechnic/build/lego_technic_main /ComputeTechnic/build/lego_technic_main
COPY --from=builder /ComputeTechnic/LEGO_Technic_data /ComputeTechnic/LEGO_Technic_data

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
