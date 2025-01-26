#!/bin/bash

# Stop on any error
set -e

# Variables
uK8S_CHANNEL="latest/stable" # Remplacez par la version souhaitée
CURRENT_USER=$USER

echo "=== Mise à jour des paquets ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installation des dépendances nécessaires ==="
sudo apt install -y curl vim tar

echo "=== Installation de uK8S ==="
sudo snap install microk8s --classic --channel=$uK8S_CHANNEL


echo "=== Configuration du kubeconfig ==="
sudo usermod -a -G microk8s $USER
mkdir -p ~/.kube
chmod 0700 ~/.kube
sudo newgrp microk8s
su - $CURRENT_USER
microk8s config > ~/.kube/config


cat <<EOF > ~/.bash_k8s
export KUBECONFIG=~/.kube/config

# alias kubectl='microk8s kubectl 

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
echo "=== Install kubectl ==="
sudo snap install kubectl --classic

echo "=== Vérification de l'accès au cluster ==="
kubectl get nodes || {
    echo "Échec de l'accès au cluster via kubectl."
    exit 1
}
echo "=== uk8s addons ==="
microk8s enable dns
microk8s enable cert-manager
# microk8s enable gpu
microk8s enable hostpath-storage
microk8s enable community
microk8s enable argocd


# echo "=== Installation de Helm (facultatif) ==="
# if ! command -v helm >/dev/null 2>&1; then
#     echo "=== Installation de Helm ==="
#     curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# else
#     echo "Helm est déjà installé."
# fi


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
# export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "=== Install kubectl plugins ==="
kubectl krew install ns


# Reload bashrc
source ~/.bashrc


echo "All installed successfully!"

