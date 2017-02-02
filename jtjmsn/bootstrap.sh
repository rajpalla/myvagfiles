fdisk -l
fdisk /dev/sda1
sudo fdisk -u /dev/sda1 <<EOF
n
p
1


t
8e
w
EOF
pvcreate /dev/sdb -y
vgextend VolGroup /dev/sdb 
lvextend /dev/VolGroup/lv_root /dev/sdb
resize2fs /dev/VolGroup/lv_root