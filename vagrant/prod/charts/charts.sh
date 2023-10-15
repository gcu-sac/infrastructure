helm repo add jetstack https://charts.jetstack.io

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.12.4 \
  --set installCRDs=true

kubectl apply -f cluster-issuer.yaml
