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
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION sh -

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
echo "Vous pouvez maintenant accéder à votre cluster avec :"
echo "export KUBECONFIG=$KUBE_CONFIG_FILE"

echo "=== Installation de Helm (facultatif) ==="
if ! command -v helm >/dev/null 2>&1; then
    echo "=== Installation de Helm ==="
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm est déjà installé."
fi

echo "=== Install argocd ==="
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Install cert-manager ==="
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml


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

# Add krew to PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "=== Install kubectl plugins ==="
kubectl krew install ns

# Alias for easy usage

cat <<EOF >> ~/.bashrc
alias k='kubectl'
complete -o default -F __start_kubectl k
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
echo 'source <(kubectl completion bash)' >>~/.bashrc
EOF

# Reload bashrc
source ~/.bashrc

echo "All installed successfully!

