# Configuration de Harbor

Ce répertoire contient la configuration de Harbor pour l'environnement ORAMD.

## Structure

- `base/`: Contient la configuration de base de Harbor, gérée par Kustomize et Helm.
  - `kustomization.yaml`: Définit la version du chart Helm de Harbor à utiliser et pointe vers le fichier `values.yaml`.
  - `values.yaml`: Contient les surcharges de configuration pour le chart Helm de Harbor.
  - `charts/`: Ce répertoire peut contenir une version locale du chart Helm de Harbor, téléchargée à des fins d'inspection et de développement. Il est ignoré par Git grâce au fichier `.gitignore`. Cela permet de comprendre la structure du chart et les options de configuration disponibles sans affecter le déploiement, qui utilise la version du chart spécifiée dans `kustomization.yaml`.
- `overlay-oramd/`: Contient les surcharges de configuration spécifiques à l'environnement ORAMD.
  - `kustomization.yaml`: Applique les patches sur la configuration de base.
  - `patch-core-recreate.yaml`: Un patch pour modifier la stratégie de déploiement du composant "core" de Harbor.

## Fonctionnement

La configuration de Harbor est déployée via ArgoCD, qui utilise l'overlay Kustomize dans `overlay-oramd/`. Cet overlay prend la configuration de base, y applique les patches spécifiques à l'environnement, et déploie le tout dans le cluster Kubernetes.