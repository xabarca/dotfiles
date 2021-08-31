#! /bin/sh

PKGS="base-files>=0.77 ncurses-devel coreutils findutils diffutils libgcc bash mksh grep gzip file sed gawk less util-linux which tar mdocml>=1.13.3 shadow dosfstools procps-ng tzdata pciutils usbutils iana-etc openssh kbd iproute2 iputils  wpa_supplicant xbps sudo  traceroute ethtool kmod acpid eudev runit-void removed-packages ca-certificates dracut linux-firmware-intel linux-firmware-network bash-completion dhcpcd git"

[ ! -d includeDir ] && mkdir -p includeDir

# doas ./mklive.sh -k es -o myvoid.iso -I includeDir -p "$PKGS" -v linux5.10 -T myvoid -b base-minimal
sudo ./mklive.sh -k es -o myvoid.iso -T myvoid -I includeDir -p "$PKGS" 

scp myvoid.iso xabarca@10.0.2.2:/tmp
