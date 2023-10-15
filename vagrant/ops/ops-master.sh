#!/usr/bin/env bash

echo ">>>> K8S Controlplane config Start <<<<"

echo "[TASK 1] Initial Kubernetes - Pod CIDR 172.16.0.0/16 , API Server 192.168.10.20"
kubeadm init --token 123456.1234567890123456 --token-ttl 0 --apiserver-advertise-address=192.168.10.20 --pod-network-cidr=172.16.128.0/17 >/dev/null 2>&1

echo "[TASK 2] Setting kube config file"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 3] Install Cilium CLI"
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum} >/dev/null 2>/dev/null
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin >/dev/null 2>/dev/null
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

echo "[TASK 4] Install Cilium"
cilium install --version 1.14.1 --set ipam.mode=kubernetes --set k8s.requireIPv4PodCIDR=true >/dev/null 2>/dev/null

echo "[TASK 5] Source the completion"
# source bash-completion for kubectl kubeadm
source <(kubectl completion bash)
source <(kubeadm completion bash)
## Source the completion script in your ~/.bashrc file
echo 'source <(kubectl completion bash)' >> /etc/profile
echo 'source <(kubeadm completion bash)' >> /etc/profile

echo "[TASK 6] Alias kubectl to k"
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile

echo "[TASK 7] Install Kubectx & Kubens"
git clone https://github.com/ahmetb/kubectx /opt/kubectx >/dev/null 2>&1
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx

echo "[TASK 8] Install Kubeps & Setting PS1"
git clone https://github.com/jonmosco/kube-ps1.git /root/kube-ps1 >/dev/null 2>&1
cat <<"EOT" >> ~/.bash_profile
source /root/kube-ps1/kube-ps1.sh
KUBE_PS1_SYMBOL_ENABLE=true
KUBE_PS1_SYMBOL_DEFAULT=🐤
function get_cluster_short() {
  echo "$1" | cut -d . -f1
}
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
KUBE_PS1_SUFFIX=') '
PS1='$(kube_ps1)'$PS1
EOT
kubectl config rename-context "kubernetes-admin@kubernetes" "$4" >/dev/null 2>&1

echo "[TASK 9] Install Packages"
apt install kubetail etcd-client -y -qq >/dev/null 2>&1

echo "[TASK 10] Install Helm"
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sed 's|${HELM_INSTALL_DIR:="/usr/local/bin"}|${HELM_INSTALL_DIR:="/usr/bin"}|g' | bash >/dev/null 2>&1

echo "[TASK 11] Install Metrics server - v0.6.1"
kubectl apply -f https://raw.githubusercontent.com/gasida/KANS/main/8/metrics-server.yaml >/dev/null 2>&1

echo "[TASK 12] Install Istio"
kubectl taint node ops-m node-role.kubernetes.io/control-plane-
curl -L https://istio.io/downloadIstio | sh - >/dev/null 2>/dev/null
cd istio-1.19.0
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y

echo "[TASK 13] Install k9s"
wget https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz >/dev/null 2>/dev/null
tar zxvf k9s_Linux_amd64.tar.gz >/dev/null 2>/dev/null
chmod +x k9s
mv k9s /usr/bin

echo ">>>> K8S Controlplane Config End <<<<"
