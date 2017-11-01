#!/bin/bash

set -ex

LOCAL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
ROOT_DIR=$(dirname "$LOCAL_DIR")

cd "$ROOT_DIR"/build

case "${BUILD_ENVIRONMENT}" in
  linux-*-cuda*)
    # Ensure ccache can find the underlying nvcc binary (also see configure.sh)
    export PATH=/usr/local/cuda/bin:$PATH
  ;;
esac

# Build
if [ "$(uname)" == "Linux" ]; then
    make "-j$(nproc)" install
else
    echo "Don't know how to build on $(uname)"
    exit 1
fi
