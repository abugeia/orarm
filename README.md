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

### Récupération du mot de passe admin par defaut pour argo cd
```
kubectl -n argocd get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

### Sealed secrets
install du client kubeseal :
```
https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#kubeseal
```
sur windows le binaire est sur [gh](https://github.com/bitnami-labs/sealed-secrets/releases)

Récupération de la public key :
```
kubeseal --fetch-cert --controller-name=sealed-secrets --controller-namespace=security > sealed-secrets.pem

```
Création d'un secret.yaml (clear) :
```
kubectl create secret generic testsecret \
  --from-literal=username=admin \
  --from-literal=password=SuperSecret123 \
  -n default \
  -o yaml --dry-run=client > secrets/clear/secret.yaml
```
Création d'un sealedsecret à partir de secret.yaml :
```
kubeseal --controller-name=sealed-secrets --controller-namespace=security --format=yaml < secrets/clear/secret.yaml > secrets/sealedsecret.yaml

```

## todo
-gestion du secret repo gh initial qui est en b64 dans le cluster



### remote conf

```
scp user@host:~/.kube/config ~/.kube/config

```
example de conf :
```
cat <<EOF >> ~/.ssh/config

Host orarm
    HostName orarm.cagou.ovh
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 6443 127.0.0.1:6443
    Port 22
EOF

ssh oram
```