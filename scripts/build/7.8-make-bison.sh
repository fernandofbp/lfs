#!/bin/bash
set -e
echo "Building bison.."
echo "Approximate build time:  0.3 SBU"
echo "Required disk space: 57 MB"

# 7.8. The Bison package contains a parser generator.
tar -xf /sources/bison-*.tar.xz -C /tmp/ \
    && mv /tmp/bison-* /tmp/bison \
    && pushd /tmp/bison \
    && ./configure --prefix=/usr            \
        --docdir=/usr/share/doc/bison-3.8.2 \
    && make \
    && make install \
    && popd \
    && rm -rf /tmp/bison
