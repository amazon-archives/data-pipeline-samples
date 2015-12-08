#!/bin/bash

# Input arguments
source=$1
destination=$2
interval=$3
backupNum=$4
efsid=$5
clientNum=$6
numClients=$7


# Prepare system for rsync
echo 'sudo yum -y install nfs-utils'
sudo yum -y install nfs-utils

if [ ! -d /backup ]; then
  echo 'sudo mkdir /backup'
  sudo mkdir /backup
  echo "sudo mount -t nfs $source /backup"
  sudo mount -t nfs $source /backup
fi
if [ ! -d /mnt/backups ]; then
  echo 'sudo mkdir /mnt/backups'
  sudo mkdir /mnt/backups
  echo "sudo mount -t nfs $destination /mnt/backups"
  sudo mount -t nfs $destination /mnt/backups
fi

if [ -f /tmp/efs-restore.log ]; then
  echo "sudo rm /tmp/efs-restore.log"
  sudo rm /tmp/efs-restore.log
fi

#Copy all content this node is responsible for
for myContent in `sudo ls -a --ignore . --ignore .. /mnt/backups/$efsid/$interval.$backupNum | awk 'NR%'$numClients==$clientNum`; do
  echo "sudo rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-restore.log /mnt/backups/$efsid/$interval.$backupNum /backup/"
  sudo rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-restore.log /mnt/backups/$efsid/$interval.$backupNum/$myContent /backup/
  rsyncStatus=$?
done

if [ -f /tmp/efs-restore.log ]; then
echo "sudo cp /tmp/efs-restore.log /mnt/backups/efsbackup-logs/$efsid-$interval.$backupNum-restore-$clientNum.$numClients-`date +%Y%m%d-%H%M`.log"
sudo cp /tmp/efs-restore.log /mnt/backups/efsbackup-logs/$efsid-$interval.$backupNum-restore-$clientNum.$numClients-`date +%Y%m%d-%H%M`.log
fi
exit $rsyncStatus
