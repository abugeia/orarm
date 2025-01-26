# orarm

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


### Initialize argoCD

```
k apply -n argocd -f app/base/argocd
k apply -n cert-manager -f security/base/cert-manager
```

## microk8s

`scp bootstrap_microk8s.sh user@host:~/`

```
ssh user@host
chmod +x bootstrap_microk8s.sh
./bootstrap_microk8s.sh
```

### accès depuis un remote

`scp user@host:~/.kube/config ~/.kube/config`

modifier l'ip du config par 127.0.0.1  
`ssh -L 16443:localhost:16443 ubuntu@orarm.cagou.ovh -N`

## k3s avec k3sup

```
export HOST="orarm.cagou.ovh"
k3sup install --host $HOST --user ubuntu \
  --ssh-key $HOME/.ssh/id_ed25519 \
  --k3s-channel stable \
  --local-path $HOME/.kube/config
```