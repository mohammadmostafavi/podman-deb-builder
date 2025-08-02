#!/bin/bash
set -e

mkdir -p /deps
cd /deps

# Use known podman runtime dependencies
DEPENDENCIES=(
  podman conmon crun runc
  netavark aardvark-dns
  slirp4netns uidmap
  libgpgme11 libseccomp2
  containers-common fuse-overlayfs
  iptables
)

echo "Downloading dependencies..."

for pkg in "${DEPENDENCIES[@]}"; do
  apt-get download "$pkg" || echo "⚠️ $pkg not downloaded (maybe virtual)"
done
