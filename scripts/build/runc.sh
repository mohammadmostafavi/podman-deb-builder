#!/bin/bash
set -e
echo "Building runc package..."
cd /src
# build runc
RUNC_LATEST_VERSION=$(curl -s https://api.github.com/repos/opencontainers/runc/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
RUNC_VERSION=${RUNC_LATEST_VERSION:1}
RUNC_DEB_DIR="runc-${RUNC_VERSION}"
RUNC_CONTROL_FILE="${RUNC_DEB_DIR}/DEBIAN/control"

echo "Last runc version: ${RUNC_LATEST_VERSION}"

if [ ! -d "runc" ]; then
  echo "Cloning runc repository..."

  git clone -b ${RUNC_LATEST_VERSION} https://github.com/opencontainers/runc.git runc
  cd runc
  make clean
  make vendor
  make verify-dependencies
  make
  make install DESTDIR="$(pwd)/${RUNC_DEB_DIR}"

  mkdir -p "${RUNC_DEB_DIR}/etc/containers"
#  curl -L -o "${RUNC_DEB_DIR}/etc/containers/registries.conf" https://raw.githubusercontent.com/containers/image/main/registries.conf
#  curl -L -o "${RUNC_DEB_DIR}/etc/containers/policy.json" https://raw.githubusercontent.com/containers/image/main/default-policy.json

else
  echo "runc already cloned, skipping clone step."
  cd runc
fi

mkdir -p "${RUNC_DEB_DIR}/DEBIAN"


cat <<EOL > "${RUNC_CONTROL_FILE}"
Package: runc
Version: ${RUNC_VERSION}
Section: admin
Priority: optional
Architecture: amd64
Depends: libc6, libseccomp2, libcap2, libsystemd0
Maintainer: Mohammad Mostafavi <mohammad@mohammadmostafavi.com>
Description: runc is a lightweight, portable container runtime.
EOL

cat <<EOF > "${RUNC_DEB_DIR}/DEBIAN/copyright"
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/
Upstream-Name: runc
Source: https://github.com/opencontainers/runc
Files: *
Copyright: 2014-2024 Open Containers Authors
License: Apache-2.0
Files: debian/*
Copyright: $(date +%Y) Mohammad Mostafavi <mohammad@mohammadmostafavi.com>
License: Apache-2.0
EOF


dpkg-deb --build "${RUNC_DEB_DIR}"
mkdir -p /build_output
mv "${RUNC_DEB_DIR}.deb" /build_output/