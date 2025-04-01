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
kubeseal --controller-name=sealed-secrets --controller-namespace=security --format=yaml < secrets/clear/secret.yaml >> secrets/sealedsecret.yaml

```

## todo
- passer le repo public
- clickhouse ? ou equivalent
- oauth2-proxy + gh ou un autre avec IdP
- monitoring ressources
- container registry => harbor nécessite amd64, ne fonctionne par avec arm
- builder
- noeud amd64
- noeud local + gpu
- knative
- code : img perso avec kubectl + python, activer DinD, faire un sercet kubeconfig et le monter dans l'img
- doc suppr d'une app

## notdo
- postgresql ? a priori il vaut mieux partir vers une instance par app lorsque nécessaire
- vault ? très (trop?) chronophage pour le déploiement
- gestion du secret repo gh initial qui est en b64 dans le cluster => public
- kubevirt + distri => essyé pmais pas d'interet pour le moment
- Secret avec clé api pour llm à monter dans n8n => géré par les credentials

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

## Vault
```
kubectl exec -it vault-0 -n security -- vault operator init
```

Save  
Unseal Key 1: YG5s0x...U1G  
Unseal Key 2: jq8LZy...Xrf  
Unseal Key 3: 7vd9Wa...Kpd  
...  
Initial Root Token: hvs.SmJxuPZ...7w

```
kubectl exec -it vault-0 -n security -- vault operator unseal <UNSEAL_KEY_1>
kubectl exec -it vault-0 -n security -- vault operator unseal <UNSEAL_KEY_2>
kubectl exec -it vault-0 -n security -- vault operator unseal <UNSEAL_KEY_3>


kubectl exec -it vault-0 -n security -- vault status
```

