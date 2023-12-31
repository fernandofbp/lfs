#!/bin/bash
set -e
echo "Building Check.."
echo "Approximate build time: 0.1 SBU (about 3.6 SBU with tests)"
echo "Required disk space: 12 MB"

# 8.55. Check is a unit testing framework for C.
tar -xf /sources/check-*.tar.gz -C /tmp/ \
    && mv /tmp/check-* /tmp/check \
    && pushd /tmp/check

./configure --prefix=/usr --disable-static
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make docdir=/usr/share/doc/check-0.15.2 install

# cleanup
popd \
    && rm -rf /tmp/check
