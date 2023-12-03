FROM nvidia/cuda:11.4.3-base-ubuntu20.04
RUN apt-get update && \
    apt-get install -y kmod build-essential wget curl lsb-release gawk libelf1

COPY additional_libs-installer.sh /entrypoint.sh

CMD /entrypoint.sh
