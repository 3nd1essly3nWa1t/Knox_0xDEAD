# scripts/carrier_killer.sh 
# Remove carrier packages 
adb shell "pm list packages | grep -E 'att|vzw|tmo|carrier|omadm|omagent|sprint' | cut -d':' -f2 | xargs -r pm uninstall -k --user 0" 

# Delete carrier configs 
rm -rf /mnt/super/system/omc/* 
rm -rf /mnt/super/vendor/omc/* 
rm -rf /mnt/super/system/priv-app/Carrier* 

# Nuke carrier IQ 
find /mnt/super -name "*carrieriq*" -exec rm -rf {} \; 
find /mnt/super -name "*mdm*" -exec rm -rf {} \; 