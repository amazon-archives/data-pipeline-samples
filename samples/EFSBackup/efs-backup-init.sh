#!/bin/bash
# Initialization of EFS backup

# Input arguments
source=$1
destination=$2
interval=$3
retain=$4
efsid=$5

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

# we need to decrement retain because we start counting with 0 and we need to remove the oldest backup
let "retain=$retain-1"
if sudo test -d /mnt/backups/$efsid/$interval.$retain; then
  echo "sudo rm -rf /mnt/backups/$efsid/$interval.$retain"
  sudo rm -rf /mnt/backups/$efsid/$interval.$retain
fi

# Rotate all previous backups (except the first one), up one level
for x in `seq $retain -1 2`; do
  if sudo test -d /mnt/backups/$efsid/$interval.$[$x-1]; then
    echo "sudo mv /mnt/backups/$efsid/$interval.$[$x-1] /mnt/backups/$efsid/$interval.$x"
    sudo mv /mnt/backups/$efsid/$interval.$[$x-1] /mnt/backups/$efsid/$interval.$x
  fi
done

# Copy first backup with hard links, then replace first backup with new backup
if sudo test -d /mnt/backups/$efsid/$interval.0 ; then
  echo "sudo cp -al /mnt/backups/$efsid/$interval.0 /mnt/backups/$efsid/$interval.1"
  sudo cp -al /mnt/backups/$efsid/$interval.0 /mnt/backups/$efsid/$interval.1
fi
if [ ! -d /mnt/backups/$efsid ]; then
  echo "sudo mkdir -p /mnt/backups/$efsid"
  sudo mkdir -p /mnt/backups/$efsid
  echo "sudo chmod 700 /mnt/backups/$efsid"
  sudo chmod 700 /mnt/backups/$efsid
fi
if [ ! -d /mnt/backups/efsbackup-logs ]; then
  echo "sudo mkdir -p /mnt/backups/efsbackup-logs"
  sudo mkdir -p /mnt/backups/efsbackup-logs
  echo "sudo chmod 700 /mnt/backups/efsbackup-logs"
  sudo chmod 700 /mnt/backups/efsbackup-logs
fi
if [ -f /tmp/efs-backup.log ]; then
  echo "sudo rm /tmp/efs-backup.log"
  sudo rm /tmp/efs-backup.log
fi
