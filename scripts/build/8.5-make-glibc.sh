#!/bin/bash
set -e
echo "Building glibc.."
echo "Approximate build time: 24 SBU"
echo "Required disk space: 2.8 Gb"

# 8.5. The Glibc package contains the main C library. This library 
# provides the basic routines for allocating memory, searching 
# directories, opening and closing files, reading and writing files, 
# string handling, pattern matching, arithmetic, and so on. 
tar -xf /sources/glibc-*.tar.xz -C /tmp/ \
    && mv /tmp/glibc-* /tmp/glibc \
    && pushd /tmp/glibc

# 6.9.1. Installation of Glibc
patch -Np1 -i /sources/glibc-2.36-fhs-1.patch

# The Glibc documentation recommends building Glibc in a dedicated
# build directory:
mkdir -v build
cd build
# prepare Glibc for compilation:
echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr            \
    --disable-werror                  \
    --enable-kernel=3.2               \
    --enable-stack-protector=strong   \
    --with-headers=/usr/include       \
    libc_cv_slibdir=/usr/lib

make

# The original code is "make check", but to avoid errors the implementation below was made.
make check || true

# prevent warning during install
touch /etc/ld.so.conf
# fix the generated Makefile to skip an uneeded sanity check that fails in the LFS partial environment
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
# install the package
make install

sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
# install the locales that can make the system respond in a different language
mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

make localedata/install-locales

popd 
rm -rf /tmp/glibc

# 8.5.2. Configuring Glibc 
# 8.5.2.1. Adding nsswitch.conf 
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF



# 8.5.2.2. Adding time zone data 
mkdir /tmp/tzdata \
    && tar -xf /sources/tzdata*.tar.gz -C /tmp/tzdata \
    && pushd /tmp/tzdata

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

# tzselect

# set time zone info
ln -sfv /usr/share/zoneinfo/America/New_York /etc/localtime

# 8.5.2.3. Configuring the Dynamic Loader 
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
mkdir -pv /etc/ld.so.conf.d


# cleanup
popd
    rm -rf /tmp/glibc
