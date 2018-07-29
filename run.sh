export QEMU_AUDIO_DRV=pa
qemu-system-x86_64 -enable-kvm -m 8G \
  -cpu host,kvm=off,hv_relaxed,hv_spinlocks=0x1fff,hv_time,hv_vapic,hv_vendor_id=0xDEADBEEFFF \
  -rtc clock=host,base=localtime \
  -smp 4,sockets=1,cores=2,threads=2 \
  -device vfio-pci,host=01:00.0,multifunction=on,x-vga=on \
  -device vfio-pci,host=01:00.1 \
  -drive if=pflash,format=raw,file=/usr/share/edk2-ovmf/OVMF_CODE.fd \
  -soundhw ac97 \
  -vga none \
  -object input-linux,id=kbd,evdev=/dev/input/by-id/usb-04d9_USB-HID_Keyboard-event-kbd,grab_all=on,repeat=on \
  -object input-linux,id=mouse,evdev=/dev/input/by-id/usb-Logitech_G102_Prodigy_Gaming_Mouse_017F36743435-event-mouse \
  -object input-linux,id=kbd2,evdev=/dev/input/by-id/usb-Logitech_G102_Prodigy_Gaming_Mouse_017F36743435-if01-event-kbd,grab_all=on,repeat=on \
  -drive id=rootfs,file=/home/alex/vfio/windoze.img.raw,id=disk,format=raw,if=none \
  -device virtio-scsi-pci,id=scsi0 \
  -device scsi-hd,bus=scsi0.0,drive=rootfs \
  -drive id=gamesfs,file=/qpool/games.img,id=disk,format=qcow2,if=none \
  -device scsi-hd,bus=scsi0.0,drive=gamesfs \
  -boot order=dc
