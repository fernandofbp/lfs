#!/bin/bash
set -e
echo "Building Shadow.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 46 MB"

# 8.25. The Shadow package contains programs for handling passwords
# in a secure way.
tar -xf /sources/shadow-*.tar.xz -C /tmp/ \
    && mv /tmp/shadow-* /tmp/shadow \
    && pushd /tmp/shadow

# Disable the installation of the groups program and its man pages,
# as Coreutils provides a better version. Also Prevent the installation
# of manual pages that were already installed by the man pages package:
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

# Instead of using the default crypt method, use the more secure SHA-512
# method of password encryption, which also allows passwords longer
# than 8 characters. It is also necessary to change the obsolete
# /var/spool/mail location for user mailboxes that Shadow uses by
# default to the /var/mail location used currently:
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:'   \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs

# Prepare Shadow for compilation:
touch /usr/bin/passwd

./configure --sysconfdir=/etc       \
    --disable-static                \
    --with-group-name-max-length=32

# Compile the package:
make

# Install the package:
make exec_prefix=/usr install
make -C man install-man

# To enable shadowed passwords, run the following command:
pwconv

# To enable shadowed group passwords, run:
grpconv

# Second, to change the default parameters, the file /etc/default/useradd needs to be created and tailored to suit your
# particular needs. Create it with:
mkdir -p /etc/default
useradd -D --gid 999

# This parameter causes useradd to create a mailbox file for the newly created user. useradd will make the group
# ownership of this file to the mail group with 0660 permissions. If you would prefer that these mailbox files are
# not created by useradd, issue the following command:
sed -i '/MAIL/s/yes/no/' /etc/default/useradd

# passwd root

# Cleanup
popd \
    && rm -rf /tmp/shadow
