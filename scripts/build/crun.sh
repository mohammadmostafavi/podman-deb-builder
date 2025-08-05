#!/bin/bash
set -e

cd /src
# build crun
CRUN_LATEST_VERSION=$(curl -s https://api.github.com/repos/containers/crun/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
CRUN_VERSION=${CRUN_LATEST_VERSION}
CRUN_DEB_DIR="crun-${CRUN_VERSION}"
CRUN_CONTROL_FILE="${CRUN_DEB_DIR}/DEBIAN/control"

echo "Last crun version: ${CRUN_LATEST_VERSION}"
# if crun is not cloned, clone it
if [ ! -d "crun" ]; then
  git clone -b ${CRUN_LATEST_VERSION} https://github.com/containers/crun.git
  cd crun

  ./autogen.sh
  ./configure
  make clean
  make BUILDTAGS="selinux seccomp"
  make install DESTDIR="$(pwd)/${CRUN_DEB_DIR}"
  libtool --finish "$(pwd)/${CRUN_DEB_DIR}/usr/local/lib"
else
  echo "crun already cloned, skipping clone step."
  cd crun
fi



for file in ${CRUN_DEB_DIR}/usr/local/*/; do
  if [ -d "$file" ]; then
    echo "Processing file: $file"
    mv "$file" "${CRUN_DEB_DIR}/usr/"
  fi
done
rm -rf "${CRUN_DEB_DIR}/usr/local"

mkdir -p "${CRUN_DEB_DIR}/DEBIAN"

cat <<EOL > "${CRUN_CONTROL_FILE}"
Package: crun
Version: ${CRUN_VERSION}
Section: utils
Priority: optional
Architecture: amd64
Depends: libc6, libseccomp2, libcap2, libsystemd0
Maintainer: Mohammad Mostafavi <mohammad@mohammadmostafavi.com>
Description: crun is a fast and lightweight container runtime for OCI containers.
EOL

dpkg-deb --build "${CRUN_DEB_DIR}"

mkdir -p /build_output
mv "${CRUN_DEB_DIR}.deb" /build_output/
