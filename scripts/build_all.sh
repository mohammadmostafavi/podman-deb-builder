#!/bin/bash

for script in /src/scripts/build/*.sh; do
  echo "Running script: $script"
  bash "$script"
done