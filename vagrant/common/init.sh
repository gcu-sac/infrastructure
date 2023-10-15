#!/usr/bin/env bash

echo ">>>> Initial Config Start <<<<"
echo "[TASK 1] Setting Root Password"
printf "qwe123\nqwe123\n" | passwd >/dev/null 2>&1

echo "[TASK 2] Setting Sshd Config"
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
systemctl restart sshd

echo "[TASK 3] Change Timezone & Install Ccat & Setting Profile & Bashrc"
# Change Timezone
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
# Install Ccat
curl -s -L https://github.com/owenthereal/ccat/releases/download/v1.1.0/linux-amd64-1.1.0.tar.gz | tar -xz  -C /tmp/
cp /tmp/linux-amd64-1.1.0/ccat /usr/local/bin/
chmod +x /usr/local/bin/ccat
#  Setting Profile & Bashrc
echo 'alias vi=vim' >> /etc/profile
echo "sudo su -" >> .bashrc
echo 'alias cat=/usr/local/bin/ccat' >> /etc/profile

echo "[TASK 4] Disable AppArmor"
systemctl stop ufw && systemctl disable ufw >/dev/null 2>&1
systemctl stop apparmor && systemctl disable apparmor >/dev/null 2>&1

echo "[TASK 5] Install Packages"
apt update -qq >/dev/null 2>&1
apt-get install sshpass bridge-utils net-tools jq tree resolvconf wireguard ngrep ipset iputils-arping ipvsadm -y -qq >/dev/null 2>&1

echo "[TASK 6] Change DNS Server IP Address"
echo -e "nameserver 1.1.1.1" > /etc/resolvconf/resolv.conf.d/head
resolvconf -u

echo "[TASK 7] Setting Local DNS Using Hosts file"
echo "192.168.10.10 master" >> /etc/hosts
echo "192.168.10.20 ops-m" >> /etc/hosts
echo "192.168.10.201 ops-w1" >> /etc/hosts
echo "192.168.10.30 nfs" >> /etc/hosts
for (( i=1; i<=3; i++  )); do echo "192.168.10.10$i worker-$i" >> /etc/hosts; done

echo "[TASK 8] Install Docker Engine"
curl -fsSL https://get.docker.com | sh >/dev/null 2>&1

echo "[TASK 9] Change Cgroup Driver Using Systemd"
cat <<EOT > /etc/docker/daemon.json
{"exec-opts": ["native.cgroupdriver=systemd"]}
EOT
systemctl daemon-reload >/dev/null 2>&1
systemctl restart docker

echo "enable containerd's cri usage"
sed -i '/disabled_plugins = \[/s/.*/disabled_plugins = \[\]/' /etc/containerd/config.toml
systemctl restart containerd

echo "[TASK 10] Disable and turn off SWAP"
swapoff -a

echo "[TASK 11] Install Kubernetes components (kubeadm, kubelet and kubectl) - v$2"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update >/dev/null 2>/dev/null
apt-get install -y kubelet kubectl kubeadm >/dev/null 2>/dev/null
apt-mark hold kubelet kubeadm kubectl >/dev/null 2>&1
systemctl enable kubelet && systemctl start kubelet

echo ">>>> Initial Config End <<<<"
