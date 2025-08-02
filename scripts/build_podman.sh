#!/bin/bash
set -e
# Get latest podman version
curl -s https://api.github.com/repos/containers/podman/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' > latest_version.txt
LATEST_VERSION=$(cat latest_version.txt)
LATEST_VERSION=${LATEST_VERSION:0:3}
# Remove the file after reading
rm latest_version.txt
# Clone and build podman deb package
git clone https://github.com/containers/podman.git
cd podman
git checkout $LATEST_VERSION
make clean
make deb

mkdir -p /build_output
cp ./debian/output/*.deb /build_output
