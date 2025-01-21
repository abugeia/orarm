# orarm


`scp bootstrap.sh user@host:~/`

```
ssh user@host
chmod +x bootstrap.sh
./bootstrap.sh
```

## Initialize argoCD
```
scp user@host:~/.kube/config ~/.kube/config
ssh -L 6443:localhost:6443 ubuntu@orarm.cagou.ovh -N
```
in another terminal
```
k apply -n argocd -f app/base/argocd
k apply -n cert-manager -f security/base/cert-manager
```