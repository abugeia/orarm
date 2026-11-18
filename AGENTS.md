# orarm

Cluster k3s Oracle Cloud (ARM) piloté par Argo CD.

## Secrets

Source de vérité des secrets en clair : projet bws **`k8s-clusters`** (partagé
avec home_kluster, plan gratuit limité à 3 projets), entrées préfixées **`ORARM_`**.

- Une entrée par manifest Secret : clé `ORARM_<NOM_DU_FICHIER>`, valeur = le
  YAML complet, `note` = `orarm/secrets/clear/<fichier>.yaml`.
- Certificat public du controller : `ORARM_SEALED_SECRETS_CERT`.
- Tout nouveau secret va dans bws **avant** d'être scellé ; ne jamais le
  laisser seulement sur un poste (`secrets/clear/` est gitignoré, local).
- Scellement : `secrets/seal_all.sh` (depuis `secrets/clear/`) ou
  `secrets/seal_all.sh --bws` (depuis bws, rien en clair sur disque).
- bw (coffre perso) ne garde que ce qu'un humain saisit : mots de passe
  d'apps, clé privée sealed-secrets.
