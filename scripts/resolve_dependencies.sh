#!/bin/bash
set -e

mkdir -p /deps
cd /deps

# Use known podman runtime dependencies
DEPENDENCIES=(
  conmon
  crun
  runc
  golang-github-containers-common
  libc6
  libdevmapper1.02.1
  libgpgme11t64
  libseccomp2
  libsqlite3-0
  libsubid4
  buildah
  catatonit
  tini
  dumb-init
  dbus-user-session
  passt
  slirp4netns
  uidmap
  containers-storage
  docker-compose
  iptables
)

echo "Downloading dependencies..."

for pkg in "${DEPENDENCIES[@]}"; do
  apt-get download "$pkg" || echo "⚠️ $pkg not downloaded (maybe virtual)"
done
