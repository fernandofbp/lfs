#!/bin/bash
set -e
echo "Building OpenSSL.."
echo "Approximate build time: 5.0 SBU"
echo "Required disk space: 476 MB"

# 8.46. The OpenSSL package contains management tools and libraries relating to cryptography.
# These are useful for providing cryptographic functions to other packages, such as OpenSSH,
# email applications and web browsers (for accessing HTTPS sites).
tar -xf /sources/openssl-*.tar.gz -C /tmp/ \
    && mv /tmp/openssl-* /tmp/openssl \
    && pushd /tmp/openssl

# prepare for compilation
./config --prefix=/usr      \
    --openssldir=/etc/ssl   \
    --libdir=lib            \
    shared                  \
    zlib-dynamic

# compile, test and install
make

# Run tests
if [ $LFS_TEST -eq 1 ]; then make test || true; fi

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

if [ $LFS_DOCS -eq 1 ]; then 
    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.5
    cp -vfr doc/* /usr/share/doc/openssl-3.0.5
fi

# cleanup
popd \
    && rm -rf /tmp/openssl
