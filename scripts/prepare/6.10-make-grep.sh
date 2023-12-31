#!/bin/bash
set -e
echo "Building grep.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 25 MB"

# 6.10. The Grep package contains programs for searching through the contents of files.
tar -xf grep-*.tar.xz -C /tmp/ \
    && mv /tmp/grep-* /tmp/grep \
    && pushd /tmp/grep \
    && ./configure --prefix=/usr    \
        --host=$LFS_TGT             \
    && make \
    && make DESTDIR=$LFS install \
    && popd \
    && rm -rf /tmp/grep
