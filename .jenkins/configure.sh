#!/bin/bash

set -ex

LOCAL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
ROOT_DIR=$(dirname "$LOCAL_DIR")

cd "$ROOT_DIR"

# Remove potential leftovers from previous build
rm -rf build install

# Run cmake from ./build directory
mkdir build
cd build

CMAKE_ARGS=("-DCMAKE_INSTALL_PREFIX=${ROOT_DIR}/install")

case "${BUILD_ENVIRONMENT}" in
  linux-*-mkl)
    CMAKE_ARGS+=("-DBLAS=MKL")
    ;;
  linux-*-cuda*)
    CMAKE_ARGS+=("-DUSE_CUDA=ON")
    CMAKE_ARGS+=("-DCUDA_ARCH_NAME=Pascal")
    CMAKE_ARGS+=("-DUSE_NNPACK=OFF")

    # Explicitly set path to NVCC such that the symlink to ccache is used
    CMAKE_ARGS+=("-DCUDA_NVCC_EXECUTABLE=/usr/local/bin/nvcc")

    # The CMake code that finds the CUDA distribution looks for nvcc in $PATH.
    # This doesn't work here, as that would yield /usr/local/bin, which doesn't
    # contain a CUDA distribution. We need it to resolve to /usr/local/cuda/bin,
    # so we add it to $PATH here. We can make CMake still use ccache by
    # specifying CUDA_NVCC_EXECUTABLE above.
    export PATH=/usr/local/cuda/bin:$PATH
    ;;
esac

# Configure
cmake .. ${CMAKE_ARGS[*]}
