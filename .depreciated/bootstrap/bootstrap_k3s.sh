#!/bin/bash

# Stop on any error
set -e

# Variables
K3S_VERSION="v1.32.0+k3s1" # Remplacez par la version souhaitée
KUBE_CONFIG_DIR="/home/$(whoami)/.kube"
KUBE_CONFIG_FILE="$KUBE_CONFIG_DIR/config"

echo "=== Mise à jour des paquets ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installation des dépendances nécessaires ==="
sudo apt install -y curl vim tar

echo "=== Installation de K3s ==="
curl -sfL https://get.k3s.io | \
INSTALL_K3S_VERSION=$K3S_VERSION \
K3S_KUBECONFIG_MODE="644" \
INSTALL_K3S_EXEC="--flannel-backend=none  --disable-network-policy" \
sh -s -



if systemctl is-active --quiet k3s; then
    echo "K3s est installé avec succès."
else
    echo "Erreur lors de l'installation de K3s."
    exit 1
fi

echo "=== Configuration du kubeconfig ==="
# Créer le répertoire kubeconfig si nécessaire
sudo mkdir -p $KUBE_CONFIG_DIR
sudo cp /etc/rancher/k3s/k3s.yaml $KUBE_CONFIG_FILE
sudo chown $(id -u):$(id -g) $KUBE_CONFIG_FILE
sudo chown -R $(id -u):$(id -g) $KUBE_CONFIG_DIR
echo "export KUBECONFIG=~/.kube/config" >> ~/.bashrc
source ~/.bashrc

# # Modifier le fichier pour un accès externe
# SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || hostname -I | awk '{print $1}')
# sed -i "s/127.0.0.1/$SERVER_IP/g" $KUBE_CONFIG_FILE

echo "=== Vérification de l'accès au cluster ==="
kubectl get nodes || {
    echo "Échec de l'accès au cluster via kubectl."
    exit 1
}
echo "=== K3s Bootstrap terminé ==="

echo "=== Configuration alias ==="
cat <<EOF > ~/.bash_k8s
export KUBECONFIG=$KUBE_CONFIG_FILE

alias k='kubectl'

alias kns='kubectl ns'

alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
# Pods and services
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kdp='kubectl describe pods'

# Logs and Exec
alias kl='kubectl logs'
alias ke='kubectl exec -it'

# helm
alias h='helm'

alias ..='cd ..'
alias ...='cd ../..'

#completion
source <(kubectl completion bash)
# etendre la completion à l'alias
complete -o default -F __start_kubectl k

EOF

cat <<EOF >> ~/.bashrc

if [ -f ~/.bash_k8s ]; then
    . ~/.bash_k8s
fi

EOF
source ~/.bashrc


if ! command -v helm >/dev/null 2>&1; then
    echo "=== Installation de Helm ==="
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm est déjà installé."
fi

echo "=== Install cilium ==="
# https://docs.k3s.io/networking/basic-network-options?_highlight=cilium&cni=Cilium#custom-cni
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
echo $CLI_ARCH
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

cilium install --version 1.16.6 --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"

cilium connectivity test

API_SERVER_IP=10.0.0.142
API_SERVER_PORT=6443
cilium install \
  --version 1.16.6 \
  --set k8sServiceHost=${API_SERVER_IP} \
  --set k8sServicePort=${API_SERVER_PORT} \
  --helm-set=operator.replicas=1

sudo iptables -A INPUT -s 10.42.0.0/16 -j ACCEPT
sudo iptables -A INPUT -s 10.43.0.0/16 -j ACCEPT
sudo su
iptables-save > /etc/iptables/rules.v4



# CILIUM_VERSION="1.14.2"
# helm repo add cilium https://helm.cilium.io/
# helm upgrade --install cilium cilium/cilium --version=${CILIUM_VERSION} \
#     --set global.tag="v${CILIUM_VERSION}" --set global.containerRuntime.integration="containerd" \
#     --set global.containerRuntime.socketPath="/var/run/k3s/containerd/containerd.sock" \
#     --set global.kubeProxyReplacement="strict" \
#     --set global.bpf.masquerade="true" \
#     --set ingressController.enabled=true \
#     --set ingressController.default=true \
#     --namespace cilium \
#     --create-namespace


# echo "=== Install calico ==="
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml

# echo "=== Install traefik v3 ==="
# helm repo add traefik https://traefik.github.io/charts
# helm repo update
# helm install traefik traefik/traefik -n kube-system

# echo "=== Install argocd ==="
# kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# echo "=== Install cert-manager ==="
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml


echo "=== Install krew ==="
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed 's/x86_64/amd64/;s/armv8l/arm64/;s/aarch64/arm64/;s/arm.*$/arm/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew &&
  rm -rf "$(mktemp -d)"
)

# # Add krew to PATH
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "=== Install kubectl plugins ==="
kubectl krew install ns

echo "All installed successfully!"

