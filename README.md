# orarm

# install 

```
kubectl apply -f security/base/cert-manager/clusterissuer.yaml

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -f argocd/helm/values.yaml -n argocd --create-namespace

kubectl apply -f argocd/repo/argocd-repo-creds.yaml -n argocd
kubectl apply -f argocd/apps/root-app.yaml -n argocd

```

## Récupération du mot de passe admin pour argo cd
kubectl -n argocd get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

## k3s
`scp bootstrap_k3s.sh user@host:~/`

```
ssh user@host
chmod +x bootstrap_k3s.sh
./bootstrap_k3s.sh
```

### accès depuis un remote

```
scp user@host:~/.kube/config ~/.kube/config
ssh -L 6443:localhost:6443 ubuntu@orarm.cagou.ovh -N
```
