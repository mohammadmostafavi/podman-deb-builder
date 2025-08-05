#!/bin/bash
set -e

REPO_TYPE="$1"
REPO_URL="$2"
REPO_USER="$3"
REPO_PASS="$4"
REPO_NAME="$5"

cd /upload

if [ "$REPO_TYPE" == "nexus" ]; then

  for deb in *.deb; do
    echo "Processing $deb..."
    filename=$(basename "$deb")
    target_url="$REPO_URL/service/rest/v1/components?repository=$REPO_NAME"

    echo "Uploading $filename → $target_url"
    echo $(
    curl -u $REPO_USER:$REPO_PASS \
      -X POST \
      -F apt.asset=@/upload/$deb \
      $target_url
    ) || {
      echo "Failed to upload $filename"
      exit 1
    }
    echo "$filename uploaded successfully."
  done
  echo "All .deb files uploaded to Nexus repository: $REPO_NAME"
else
  echo "Unsupported yet repository type: $REPO_TYPE"
  exit 1
fi
