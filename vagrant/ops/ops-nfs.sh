#!/usr/bin/env bash

echo "Install NFS Client"
apt update >/dev/null 2>/dev/null
apt install -y -qq nfs-common >/dev/null 2>/dev/null

mkdir -p /mnt/nfs/ops
mount -t nfs -o vers=4 192.168.10.30:/mnt/nfs/ops /mnt/nfs/ops

helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.10.30 --set nfs.path=/mnt/nfs/ops
