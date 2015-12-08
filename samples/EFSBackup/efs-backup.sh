#!/bin/bash
# Example would be to run this script as follows:
# Every 6 hours; retain last 4 backups
# efs-backup.sh $src $dst hourly 4 efs-12345
# Once a day; retain last 31 days
# efs-backup.sh $src $dst daily 31 efs-12345
# Once a week; retain 4 weeks of backup
# efs-backup.sh $src $dst weekly 7 efs-12345
# Once a month; retain 3 months of backups
# efs-backup.sh $src $dst monthly 3 efs-12345
#
# Snapshots will look like:
# $dst/$efsid/hourly.0-3; daily.0-30; weekly.0-3; monthly.0-2


# Input arguments
source=$1
destination=$2
interval=$3
retain=$4
efsid=$5

# Prepare system for rsync
#echo 'sudo yum -y update'
#sudo yum -y update
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
echo "sudo rm /tmp/efs-backup.log"
sudo rm /tmp/efs-backup.log
echo "sudo rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-backup.log /backup/ /mnt/backups/$efsid/$interval.0/"
sudo rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-backup.log /backup/ /mnt/backups/$efsid/$interval.0/
rsyncStatus=$?
echo "sudo cp /tmp/efs-backup.log /mnt/backups/efsbackup-logs/$efsid-`date +%Y%m%d-%H%M`.log"
sudo cp /tmp/efs-backup.log /mnt/backups/efsbackup-logs/$efsid-`date +%Y%m%d-%H%M`.log
echo "sudo touch /mnt/backups/$efsid/$interval.0/"
sudo touch /mnt/backups/$efsid/$interval.0/
exit $rsyncStatus
