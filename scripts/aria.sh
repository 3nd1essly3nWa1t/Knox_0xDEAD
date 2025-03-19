#!/bin/bash 

# Extract AP 
7z x firmware/original/AP_*.tar.md5 -o/tmp 

# Decompress boot.img 
lz4 -d /tmp/boot.img.lz4 /tmp/boot.img 

# Modify boot.img 
cd tools/Android-Image-Kitchen 
./unpackimg.sh /tmp/boot.img 

# Inject ADB persistence 
echo 'on property:sys.boot_completed=1' >> ramdisk/init.rc 
echo '    setprop service.adb.tcp.port 5555' >> ramdisk/init.rc 
echo '    start adbd' >> ramdisk/init.rc 

./repackimg.sh 
mv image-new.img /tmp/boot.img 

# Recompress 
lz4 -B6 --content-size /tmp/boot.img /tmp/boot.img.lz4 

# Debloat super.img 
simg2img /tmp/super.img /tmp/super.raw.img 
mkdir /mnt/super 
mount -t ext4 /tmp/super.raw.img /mnt/super 

while read -r pkg; do 
  find /mnt/super -name "*$pkg*" -exec rm -rf {} \; 
done < ../scripts/debloat_list.txt 

umount /mnt/super 
img2simg /tmp/super.raw.img /tmp/super.img 

# Build modified AP 
cd /tmp 
tar -H ustar -cvf ../firmware/modified/AP_KNOCKNEXUS.tar.md5 *
```

---