FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y kmod build-essential wget curl lsb-release gawk libelf1

COPY encode-installer.sh /entrypoint.sh

CMD /entrypoint.sh