#!/bin/bash

# Input arguments
interval=$1
efsid=$2

echo "sudo touch /mnt/backups/$efsid/$interval.0/"
sudo touch /mnt/backups/$efsid/$interval.0/
echo "$interval: completed successfully"
