#!/bin/bash
# Copyright 2021 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x
NVIDIA_DRIVER_BRANCH="${NVIDIA_DRIVER_BRANCH:-tesla}"
NVIDIA_DRIVER_VERSION="${NVIDIA_DRIVER_VERSION:-384.111}"
NVIDIA_INSTALL_DIR_HOST="${NVIDIA_INSTALL_DIR_HOST:-/var/lib/nvidia}"
NVIDIA_INSTALL_DIR_CONTAINER="${NVIDIA_INSTALL_DIR_CONTAINER:-/usr/local/nvidia}"
ROOT_MOUNT_DIR="${ROOT_MOUNT_DIR:-/root}"
CACHE_FILE="${NVIDIA_INSTALL_DIR_CONTAINER}/.cache"
KERNEL_VERSION="$(uname -r)"
set +x


configure_nvidia_installation_dirs() {
  echo "Configuring installation directories..."
  mkdir -p "${NVIDIA_INSTALL_DIR_CONTAINER}"
  pushd "${NVIDIA_INSTALL_DIR_CONTAINER}"

  # nvidia-installer does not provide an option to configure the
  # installation path of `nvidia-modprobe` utility and always installs it
  # under /usr/bin. The following workaround ensures that
  # `nvidia-modprobe` is accessible outside the installer container
  # filesystem.
  mkdir -p bin bin-workdir
  mount -t overlay -o lowerdir=/usr/bin,upperdir=bin,workdir=bin-workdir none /usr/bin

  # nvidia-installer does not provide an option to configure the
  # installation path of libraries such as libnvidia-ml.so. The following
  # workaround ensures that the libs are accessible from outside the
  # installer container filesystem.
  mkdir -p lib64 lib64-workdir
  mkdir -p /usr/lib/x86_64-linux-gnu
  mount -t overlay -o lowerdir=/usr/lib/x86_64-linux-gnu,upperdir=lib64,workdir=lib64-workdir none /usr/lib/x86_64-linux-gnu

  # nvidia-installer does not provide an option to configure the
  # installation path of driver kernel modules such as nvidia.ko. The following
  # workaround ensures that the modules are accessible from outside the
  # installer container filesystem.
  mkdir -p drivers drivers-workdir
  mkdir -p /lib/modules/${KERNEL_VERSION}/video
  mount -t overlay -o lowerdir=/lib/modules/${KERNEL_VERSION}/video,upperdir=drivers,workdir=drivers-workdir none /lib/modules/${KERNEL_VERSION}/video

  # Install an exit handler to cleanup the overlayfs mount points.
  trap "{ umount /lib/modules/${KERNEL_VERSION}/video; umount /usr/lib/x86_64-linux-gnu ; umount /usr/bin; }" EXIT
  popd
  echo "Configuring installation directories... DONE."
}
installLib(){
  SHIPPED_NVIDIA_DRIVER_VERSION="$(cat /var/lib/nvidia/shipped-nvidia-version)"
  echo "NVIDIA driver is $SHIPPED_NVIDIA_DRIVER_VERSION"
  apt update
  UBUNTU_PACKAGE_VERSION="$(apt list libnvidia-cfg1-470 -a | grep $SHIPPED_NVIDIA_DRIVER_VERSION | awk '{print $2}')"
  echo "Ubuntu package version is $UBUNTU_PACKAGE_VERSION"
  apt install -y --no-install-recommends libnvidia-cfg1-470=$UBUNTU_PACKAGE_VERSION libnvidia-encode-470=$UBUNTU_PACKAGE_VERSION libnvidia-compute-470=$UBUNTU_PACKAGE_VERSION libnvidia-decode-470=$UBUNTU_PACKAGE_VERSION
  export DEBIAN_FRONTEND=noninteractive
  apt install -y --no-install-recommends xserver-xorg-video-nvidia-470=$UBUNTU_PACKAGE_VERSION
}

main() {
    configure_nvidia_installation_dirs
    installLib
}

main "$@"
