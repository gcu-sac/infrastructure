#!/usr/bin/env bash

echo "Install NFS Client"
apt update > /dev/null 2>/dev/null
apt install nfs-common -y -qq > /dev/null 2>/dev/null

mkdir -p /mnt/nfs/prod
mount -t nfs -o vers=4 192.168.10.30:/mnt/nfs/prod /mnt/nfs/prod

