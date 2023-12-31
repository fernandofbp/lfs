#!/bin/bash
set -e
echo "Building perl.."
echo "Approximate build time: 8.4 SBU"
echo "Required disk space: 257 MB"

# 8.41. The Perl package contains the Practical Extraction and Report Language
tar -xf /sources/perl-*.tar.xz -C /tmp/ \
    && mv /tmp/perl-* /tmp/perl \
    && pushd /tmp/perl

# use libs installed in system
export BUILD_ZLIB=False
export BUILD_BZIP2=0

# configure
sh Configure -des                                   \
    -Dprefix=/usr                                   \
    -Dvendorprefix=/usr                             \
    -Dprivlib=/usr/lib/perl5/5.36/core_perl         \
    -Darchlib=/usr/lib/perl5/5.36/core_perl         \
    -Dsitelib=/usr/lib/perl5/5.36/site_perl         \
    -Dsitearch=/usr/lib/perl5/5.36/site_perl        \
    -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl     \
    -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl    \
    -Dman1dir=/usr/share/man/man1                   \
    -Dman3dir=/usr/share/man/man3                   \
    -Dpager="/usr/bin/less -isR"                    \
    -Duseshrplib                                    \
    -Dusethreads

# Compile the package:
make

# Several tests related to zlib will fail due to using the system
# version of zlib instead of the internal version
if [ $LFS_TEST -eq 1 ]; then make -k test || true; fi

# Install the package and clean up:
make install
unset BUILD_ZLIB BUILD_BZIP2

# Cleanup
popd \
    && rm -rf /tmp/perl
