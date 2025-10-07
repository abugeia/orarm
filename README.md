# orarm

## todo
- clickhouse ? ou equivalent
- ameliorer oauth2-proxy (IdP ?)
- monitoring ressources
- builder
- noeud local + gpu
- knative
- code : img perso avec kubectl + python, activer DinD, faire un secret kubeconfig et le monter dans l'img
- doc rm d'une app
- kestra
- remplacer le domaine par une var dans les manifest


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

Host conn_name
    HostName host
    User user
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 6443 127.0.0.1:6443
    Port 22
EOF

ssh oram
```


