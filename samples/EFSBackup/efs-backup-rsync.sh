#!/bin/bash

# Input arguments
source=$1
destination=$2
interval=$3
retain=$4
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

if [ -f /tmp/efs-backup.log ]; then
  echo "sudo rm /tmp/efs-backup.log"
  sudo rm /tmp/efs-backup.log
fi

#Copy all content this node is responsible for
for myContent in `sudo ls -a --ignore . --ignore .. /backup/ | awk 'NR%'$numClients==$clientNum`; do
  echo "sudo rsync -s -ah --stats --delete --numeric-ids --log-file=/tmp/efs-backup.log /backup/$myContent /mnt/backups/$efsid/$interval.0/"
  sudo rsync -s -ah --stats --delete --numeric-ids --log-file=/tmp/efs-backup.log /backup/"$myContent" /mnt/backups/$efsid/$interval.0/
  rsyncStatus=$?
done

if [ -f /tmp/efs-backup.log ]; then
echo "sudo cp /tmp/efs-backup.log /mnt/backups/efsbackup-logs/$efsid-$clientNum.$numClients-`date +%Y%m%d-%H%M`.log"
sudo cp /tmp/efs-backup.log /mnt/backups/efsbackup-logs/$efsid-$clientNum.$numClients-`date +%Y%m%d-%H%M`.log
fi
exit $rsyncStatus
