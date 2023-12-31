#!/bin/bash
set -e
echo "Building Libstdc++ from GCC .."
echo "Approximate build time: 0.4 SBU"
echo "Required disk space: 1.1 MB"

# 5.6. Libstdc++ is the standard C++ library. It is needed to 
# compile C++ code (part of GCC is written in C++), but we had
# to defer its installation when we built gcc-pass1 because 
# it depends on glibc, which was not yet available in the target
# directory.
tar -xf gcc-*.tar.xz -C /tmp/ \
    && mv /tmp/gcc-* /tmp/gcc \
    && pushd /tmp/gcc \
    && mkdir -v build \
    && cd build \
    && ../libstdc++-v3/configure                                    \
        --host=$LFS_TGT                                             \
        --build=$(../config.guess)                                  \
        --prefix=/usr                                               \
        --disable-multilib                                          \
        --disable-nls                                               \
        --disable-libstdcxx-pch                                     \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/12.2.0   \
    && make \
    && make DESTDIR=$LFS install \
    && rm -v $LFS/usr/lib/lib{stdc++,stdc++fs,supc++}.la \
    && cd .. \
    && popd \
    && rm -rf /tmp/gcc