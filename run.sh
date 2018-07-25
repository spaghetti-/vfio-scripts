qemu-system-x86_64 -enable-kvm -m 8G -cpu host,kvm=off \
    -smp 4,sockets=1,cores=2,threads=2 \
    -device vfio-pci,host=01:00.0,multifunction=on,romfile=patched_rom \
    -device vfio-pci,host=01:00.1 \
    -drive if=pflash,format=raw,file=/usr/share/edk2-ovmf/OVMF_CODE.fd \
    -drive media=cdrom,file=win10.iso,id=virtiocd1,if=none \
    -device ide-cd,bus=ide.1,drive=virtiocd1 \
    -vga none \
    -object input-linux,id=kbd,evdev=/dev/input/by-id/usb-04d9_USB_Keyboard-event-kbd,grab_all=on,repeat=on \
    -object input-linux,id=mouse,evdev=/dev/input/by-id/usb-Logitech_G102_Prodigy_Gaming_Mouse_017F36743435-event-mouse \
    -drive file=windoze2,id=disk,format=qcow2,if=none \
    -device ide-hd,bus=ide.1,drive=disk \
    -boot order=dc \
    -drive media=cdrom,file=/usr/share/drivers/windows/virtio-win-0.1.141.iso


# x-vga=on is not required after 2.20(?) lands in portage ~amd64
export QEMU_AUDIO_DRV=pa QEMU_AUDIO_TIMER_PERIOD=0 QEMU_PA_SAMPLES=8192
export QEMU_AUDIO_DRV=alsa QEMU_AUDIO_TIMER_PERIOD=0
qemu-system-x86_64 -enable-kvm -m 8G -cpu host,kvm=off \
    -smp 4,sockets=1,cores=2,threads=2 \
    -device vfio-pci,host=01:00.0,multifunction=on,romfile=patched_rom,x-vga=on \
    -device vfio-pci,host=01:00.1 \
    -drive if=pflash,format=raw,file=/usr/share/edk2-ovmf/OVMF_CODE.fd \
    -drive media=cdrom,file=win10.iso,id=virtiocd1,if=none \
    -device ide-cd,bus=ide.1,drive=virtiocd1 \
    -soundhw ac97 \
    -vga none \
    -object input-linux,id=kbd,evdev=/dev/input/by-id/usb-04d9_USB_Keyboard-event-kbd,grab_all=on,repeat=on \
    -object input-linux,id=mouse,evdev=/dev/input/by-id/usb-Logitech_G102_Prodigy_Gaming_Mouse_017F36743435-event-mouse \
    -object input-linux,id=kbd2,evdev=/dev/input/by-id/usb-Logitech_G102_Prodigy_Gaming_Mouse_017F36743435-if01-event-kbd,grab_all=on,repeat=on \
    -drive id=rootfs,file=windoze2,id=disk,format=qcow2,if=none \
    -device virtio-scsi-pci,id=scsi0 \
    -device scsi-hd,bus=scsi0.0,drive=rootfs \
    -drive id=gamesfs,file=/media/VMSTORE/games.img,id=disk,format=qcow2,if=none \
    -device scsi-hd,bus=scsi0.0,drive=gamesfs \
    -boot order=dc \
    -drive media=cdrom,file=/usr/share/drivers/windows/virtio-win-0.1.141.iso
