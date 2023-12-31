#!/bin/bash
set -e
echo "Building Gzip.."
echo "Approximate build time: 0.3 SBU"
echo "Required disk space: 21 MB"

# 8.61. The Gzip package contains programs for compressing and
# decompressing files.
tar -xf /sources/gzip-*.tar.xz -C /tmp/ \
    && mv /tmp/gzip-* /tmp/gzip \
    && pushd /tmp/gzip

./configure --prefix=/usr
make

# NOTE two tests are known to fail in the LFS environment: help-version and zmore
if [ $LFS_TEST -eq 1 ]; then make check || true; fi

# Install the package:
make install

# cleanup
popd \
    && rm -rf /tmp/gzip
