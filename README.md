# orarm

## todo
- clickhouse ? ou equivalent
- oauth2-proxy + gh ou un autre avec IdP
- monitoring ressources
- container registry => harbor nécessite amd64, ne fonctionne par avec arm
- builder
- noeud local + gpu
- knative
- code : img perso avec kubectl + python, activer DinD, faire un sercet kubeconfig et le monter dans l'img
- doc rm d'une app
- kestra
- remplacer le domaine par une var dans les manifest

## notdo
- postgresql ? a priori il vaut mieux partir vers une instance par app lorsque nécessaire
- vault ? très (trop?) chronophage pour le déploiement
- kubevirt + distri => essayé mais pas d'interet pour le moment
- Secret avec clé api pour llm à monter dans n8n => géré par les credentials


# install 

```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -f argocd/helm/values.yaml -n argocd --create-namespace

kubectl apply -f argocd/apps/root-app.yaml -n argocd
```

### Récupération du mot de passe admin par defaut pour argo cd
```
kubectl -n argocd get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

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


