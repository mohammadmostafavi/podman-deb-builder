#!/bin/bash
set -e

NEXUS_URL="$1"
NEXUS_USER="$2"
NEXUS_PASS="$3"
REPO_NAME="$4"

cd /upload

for deb in *.deb; do
  filename=$(basename "$deb")
  target_url="$NEXUS_URL/repository/$REPO_NAME/pool/main/${filename:0:1}/${filename%%_*}/$filename"

  echo "Uploading $filename → $target_url"
  curl -u "$NEXUS_USER:$NEXUS_PASS" --upload-file "$deb" "$target_url"
done
