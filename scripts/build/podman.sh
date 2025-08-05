#!/bin/bash
set -e

cd /src
# build podman
PODMAN_LATEST_VERSION=$(curl -s https://api.github.com/repos/containers/podman/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
PODMAN_VERSION=${PODMAN_LATEST_VERSION:1}
PODMAN_DEB_DIR="podman-${PODMAN_VERSION}"
PODMAN_CONTROL_FILE="${PODMAN_DEB_DIR}/DEBIAN/control"
PODMAN_COMPAT_FILE="${PODMAN_DEB_DIR}/DEBIAN/compat"

echo "Last podman version: ${PODMAN_LATEST_VERSION}"
if [ ! -d "podman" ]; then
  git clone -b ${PODMAN_LATEST_VERSION} https://github.com/containers/podman.git
  cd podman
  make clean
  make BUILDTAGS="seccomp selinux systemd apparmor rootlessport"
  make install PREFIX="$(pwd)/${PODMAN_DEB_DIR}/usr/local"
else
  echo "Podman already cloned, skipping clone step."
  cd podman
fi


mkdir -p "${PODMAN_DEB_DIR}/DEBIAN"


echo "13" > "${PODMAN_COMPAT_FILE}"

cat <<EOL > "${PODMAN_CONTROL_FILE}"
Package: podman
Version: ${PODMAN_VERSION}
Section: admin
Priority: optional
Architecture: amd64
Depends: conmon, crun, runc, golang-github-containers-common, libc6, libdevmapper1.02.1, libgpgme11t64, libseccomp2, libsqlite3-0, libsubid4
Recommends: buildah, catatonit, tini, dumb-init, dbus-usersession, passt, slirp4netns, uidmap
Suggests: containers-storage, docker-compose, iptables
Conflicts: docker
Maintainer: Mohammad Mostafavi <mohammad@mohammadmostafavi.com>
Description: A tool for managing pods, containers and container images
 Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux system.
EOL


cat <<EOF > "${PODMAN_DEB_DIR}/DEBIAN/copyright"
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: podman
Source: https://github.com/containers/podman

Files: *
Copyright: 2017-2024 Red Hat, Inc. and others
License: Apache-2.0

Files: debian/*
Copyright: $(date +%Y) Mohammad Mostafavi <mohammad@mohammadmostafavi.com>
License: Apache-2.0
EOF


for files in bin/*; do
  if [ -f "$files" ]; then
    echo "Processing file: $files"
    cp "$files" "${PODMAN_DEB_DIR}/usr/local/bin/"
  fi
done


mkdir -p "${PODMAN_DEB_DIR}/usr/local/share/bash-completion/completions"

for file in contrib/completions/bash/*; do
  if [ -f "$file" ]; then
    echo "Processing bash completion file: $file"
    cp "$file" "${PODMAN_DEB_DIR}/usr/local/share/bash-completion/completions/"
  fi
done

# replace ${pwd}/${PODMAN_DEB_DIR} with '' in the files
find "${PODMAN_DEB_DIR}/usr/local" -type f -exec sed -i "s|${PWD}/${PODMAN_DEB_DIR}||g" {} +

dpkg-deb --build "${PODMAN_DEB_DIR}"

mkdir -p /build_output
mv "${PODMAN_DEB_DIR}.deb" /build_output/
