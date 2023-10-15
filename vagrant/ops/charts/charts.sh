helm repo add jenkinsci https://charts.jenkins.io
helm repo add jetstack https://charts.jetstack.io

helm install jenkins jenkinsci/jenkins -n jenkins --create-namespace --set persistence.storageClass=nfs-client

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.4 \
  --set installCRDs=true

kubectl apply -f cluster-issuer.yaml


