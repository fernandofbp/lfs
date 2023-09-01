#!/bin/bash
set -e
echo "Building linux kernel.."
echo "Approximate build time: 4.4 - 66.0 SBU (typically about 6 SBU)"
echo "Required disk space: 960 - 4250 MB (typically about 1100 MB)"

# 10.3. Linux package contains the Linux kernel
tar -xf /sources/linux-*.tar.xz -C /tmp/ \
    && mv /tmp/linux-* /tmp/linux \
    && pushd /tmp/linux

# 10.3.1 install kernel
# clean source tree
make mrproper

# copy premade config
# NOTE manual way is by launching:
# make menuconfig
cp /config/kernel-5.19.2.config .config

# compile
make

# installation
make modules_install

# copy kernel image
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.19.2-lfs-11.2

# copy symbols
cp -iv System.map /boot/System.map-5.19.2

# copy original configuration
cp -iv .config /boot/config-5.19.2

# install documentation
install -d /usr/share/doc/linux-5.19.2
cp -r Documentation/* /usr/share/doc/linux-5.19.2

# 10.3.2. configure linux module load order
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf
install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
# End /etc/modprobe.d/usb.conf
EOF

# cleanup
popd \
    && rm -rf /tmp/linux