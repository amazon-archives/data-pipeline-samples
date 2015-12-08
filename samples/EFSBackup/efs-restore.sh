#!/bin/bash

# Input arguments
source=$1
destination=$2
interval=$3
backupNum=$4
efsid=$5

# Prepare system for rsync
echo 'sudo yum -y install nfs-utils'
sudo yum -y install nfs-utils
echo 'sudo mkdir /backup'
sudo mkdir /backup
echo 'sudo mkdir /mnt/backups'
sudo mkdir /mnt/backups
echo "sudo mount -t nfs $source /backup"
sudo mount -t nfs $source /backup
echo "sudo mount -t nfs $destination /mnt/backups"
sudo mount -t nfs $destination /mnt/backups

if [ ! sudo test -d /mnt/backups/$efsid/$interval.$backupNum/ ]; then
  echo "EFS Backup $efsid/$interval.$backupNum does not exist!"
  exit 1
fi

echo "sudo rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-restore.log /mnt/backups/$efsid/$interval.$backupNum/ /backup/"
sudo rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-restore.log /mnt/backups/$efsid/$interval.$backupNum/ /backup/
rsyncStatus=$?
echo "sudo cp /tmp/efs-restore.log /mnt/backups/efsbackup-logs/$efsid-$interval.$backupNum-restore-`date +%Y%m%d-%H%M`.log"
sudo cp /tmp/efs-restore.log /mnt/backups/efsbackup-logs/$efsid-$interval.$backupNum-restore-`date +%Y%m%d-%H%M`.log
exit $rsyncStatus
