#!/bin/bash

# Extract AP
7z x firmware/original/AP_*.tar.md5 -o/tmp

# Decompress boot.img
lz4 -d /tmp/boot.img.lz4 /tmp/boot.img

# Modify boot.img
cd tools/Android-Image-Kitchen
./unpackimg.sh /tmp/boot.img

# Inject ADB persistence
echo 'on property.sys.boot_completed=1' >> ramdisk/init.rc
echo '    setprop service.adb.tcp.port 5555' >> ramdisk/init.rc
echo '    start adbd' >> ramdisk/init.rc

./repacking.sh
mv image-new.img /tmp/boot.img

# Recompress
lz4 -B6 --content-size /tmp/boot.img /tmp/boot.img.lz4

# Debloat super.img
simg2img /tmp/super.img /tmp/super.raw.img
mkdir -p /mnt/super
mount -t ext4 /tmp/super.raw.img /mnt/super

# Inject custom boot animation and sounds
echo "[+] Replacing boot animation and sounds..."
cp -rf $GITHUB_WORKSPACE/scripts/grunge/*.ogg /mnt/super/system/media/audio/ui/
cp $GITHUB_WORKSPACE/scripts/grunge/bootanimation.zip /mnt/super/system/media/

# Fix permissions
chmod 644 /mnt/super/system/media/audio/ui/*.ogg
chmod 644 /mnt/super/system/media/bootanimation.zip

# Cleanup
umount /mnt/super
img2simg /tmp/super.raw.img /tmp/super.img

# Build modified AP
cd /tmp
tar -H ustar -cvf $GITHUB_WORKSPACE/firmware/modified/AP_KNOCKNEXUS.tar.md5 *