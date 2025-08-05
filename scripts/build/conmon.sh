#!/bin/bash

set -e
cd /src
# build conmon
CONMON_LATEST_VERSION=$(curl -s https://api.github.com/repos/containers/conmon/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
CONMON_VERSION=${CONMON_LATEST_VERSION:1}
CONMON_DEB_DIR="conmon-${CONMON_VERSION}"
CONMON_CONTROL_FILE="${CONMON_DEB_DIR}/DEBIAN/control"

echo "Last conmon version: ${CONMON_LATEST_VERSION}"

if [ ! -d "conmon" ]; then
  git clone -b ${CONMON_LATEST_VERSION} https://github.com/containers/conmon
  cd conmon
  make
  make install PREFIX="$(pwd)/${CONMON_DEB_DIR}/usr/local/"
  make podman PREFIX="$(pwd)/${CONMON_DEB_DIR}/usr/local/"
  make crio PREFIX="$(pwd)/${CONMON_DEB_DIR}/usr/local/"
else
  echo "Conmon already cloned, skipping clone step."
  cd conmon
fi

mkdir -p "${CONMON_DEB_DIR}/DEBIAN"

cat <<EOL > "${CONMON_CONTROL_FILE}"
Package: conmon
Version: ${CONMON_VERSION}
Section: admin
Priority: optional
Architecture: amd64
Depends: libc6, libseccomp2, libcap2, libsystemd0
Recommends: runc, crun, podman, cri-o
Maintainer: Mohammad Mostafavi <mohammad@mohammadmostafavi.com>
Description: conmon is a lightweight container monitor for OCI containers.
EOL

dpkg-deb --build "${CONMON_DEB_DIR}"
mkdir -p /build_output
mv "${CONMON_DEB_DIR}.deb" /build_output/
