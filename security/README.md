
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
flag pour le cert
`--cert=secrets/clear/sealed-secret.pem`


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