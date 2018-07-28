#!/bin/sh

# PCIe device ids
GPU=0000:01:00.0
GPU_SND=0000:01:00.1
PCI_BRIDGE=0000:00:01.0

# this script is intended to be run as root
# @TODO put in a check against whoami or $USER

function perror() {
	echo "$@" 1>&2;
}

function bus_rescan() {
	perror "[*] rescaning pci bus"
	echo 1 > /sys/bus/pci/rescan
}

# usage
# vfio-bind $GPU vfio-bind
function driver_bind() {
	DEV="$1"
	DRV="$2"
	VENDOR=$(< /sys/bus/pci/devices/$DEV/vendor)
	DEVICE=$(< /sys/bus/pci/devices/$DEV/device)
	if [ -e /sys/bus/pci/devices/$DEV/driver ]; then
		perror "[*] unbinding $DEV"
		echo $DEV > /sys/bus/pci/devices/$DEV/driver/unbind
		sleep .5
	else
		perror "[!] existing driver for $DEV not found"
	fi
	perror "[*] binding $DEV to $DRV"
	echo $VENDOR $DEVICE > /sys/bus/pci/drivers/$DRV/new_id
}

function remove_pci_bridge() {
	perror "[*] removing pci bridge"
	echo 1 > /sys/bus/pci/devices/$PCI_BRIDGE/remove
	bus_rescan
}

function unbind_fb_vtconsole() {
	perror "[*] removing efifb and vtconsole binding"
	perror "[!!] you WILL lose console"
	echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/unbind
	sleep 1
	echo 0 > /sys/class/vtconsole/vtcon0/bind
	sleep 1
	echo 0 > /sys/class/vtconsole/vtcon1/bind
}

function rebind_fb_vtconsole() {
	#echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
	echo 1 > /sys/class/vtconsole/vtcon0/bind
	sleep 1
	echo 1 > /sys/class/vtconsole/vtcon1/bind
}

#
function intel() {
	killall X
	sleep 5

	#unbind_fb_vtconsole
	driver_bind $GPU vfio-pci
	driver_bind $GPU_SND vfio-pci
	remove_pci_bridge

	perror "[*] switching monitor 1 to mDP"
	ddccontrol -r 0x60 -w 16 dev:/dev/i2c-3

	touch /tmp/vm.lock
	su alex -c startx
}

function host() {
	killall X
	sleep 5

	driver_bind $GPU nvidia
	driver_bind $GPU_SND snd_hda_intel
	bus_rescan

	rm /tmp/vm.lock
	ddccontrol -r 0x60 -w 15 dev:/dev/i2c-3
	#rebind_fb_vtconsole()
	su alex -c startx
}

if [ "$1" == "vm" ]; then
	intel
elif [ "$1" == "host" ]; then
	host
fi
