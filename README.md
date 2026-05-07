# Système Cloud & DevOps : API Lacets Connectés (K3s & Monitoring) Lewandowski Valentin, Dumas Philippe

Ce projet propose une solution automatisée pour déployer une infrastructure complète de type Cloud. Il orchestre une API Node.js/Express connectée à une base MySQL sous Kubernetes, avec une chaîne de livraison continue (CI/CD) via GitHub Actions et un écosystème de surveillance Prometheus/Grafana.

##  Architecture du Projet

Le dépôt est organisé pour séparer les responsabilités :

*   **`app/`** : Code source de l'API (Node.js/Express). Inclut un `Dockerfile` pour la production et des sondes de santé (`/health`).
*   **`infra/`** : Infrastructure as Code (IaC). Gestion des deux VM Debian via **Vagrant** et provisionnement logiciel par **Ansible**.
*   **`k8s/`** : Manifestes Kubernetes (Namespace `lacets-connecte`, MySQL StatefulSet, PVC, Deployment API, et HPA).
*   **`.github/workflows/deploy.yml`** : Pipeline CI/CD automatisant le build Docker et la mise à jour du cluster.

### Adressage Réseau Fixe

Pour faciliter la démonstration, les machines utilisent des adresses IP statiques :

| Machine | Adresse IP | Rôle & Services |
| :--- | :--- | :--- |
| **`k3s`** | `192.168.56.10` | Cluster K3s, Moteur Docker, Runner GitHub Actions |
| **`monitoring`** | `192.168.56.20` | Prometheus, Grafana, Node Exporter |

---

##  Configuration & Prérequis

### Logiciels nécessaires
*   VirtualBox & Vagrant
*   Ansible (local ou via WSL2)
*   Compte Docker Hub et Dépôt GitHub

### Initialisation des accès SSH (Utilisateurs WSL2)
Afin d'éviter les problèmes de droits sur les fichiers Windows, copiez la clé sécurisée de Vagrant dans votre environnement Linux :

```bash
mkdir -p ~/.ssh
cp "/mnt/c/Users/kilaw/.vagrant.d/insecure_private_key" ~/.ssh/vagrant_insecure_key
chmod 600 ~/.ssh/vagrant_insecure_key
```

---

##  Déploiement de l'Infrastructure

Pour monter l'ensemble des services, exécutez la commande suivante à la racine :

```bash
# Lancement combiné Vagrant + Ansible
bash infra/scripts/bootstrap.sh
```

**Ce playbook automatise :**
1.  L'installation de **K3s** et **Docker** sur le nœud applicatif.
2.  Le déploiement de **node_exporter** sur les deux hôtes.
3.  La configuration de **Prometheus** et **Grafana** sur le nœud dédié.
4.  L'importation automatique du dashboard Grafana "Node Exporter Full" (ID `1860`).

---

##  Automatisation CI/CD (GitHub Actions)

Le déploiement de l'application métier est géré par un **self-hosted runner** situé sur la VM `k3s`.

1.  **Enregistrement :** Allez sur GitHub (`Settings > Actions > Runners`) pour obtenir un token.
2.  **Liaison :** `bash infra/scripts/register-runner.sh [https://github.com/](https://github.com/)<user>/<repo> <token>`
3.  **Secrets :** Ajoutez `DOCKERHUB_USERNAME` et `DOCKERHUB_TOKEN` dans les secrets de votre dépôt.
4.  Il vous sera peut être nécessaire de modifier et ajouter votre pseudo dans le deploy.yaml à la place de l'actuel "phidums" pour que l'envoie vers docker fonctionne correctement

---

##  Orchestration Kubernetes

L'application est cloisonnée dans le namespace `lacets-connecte`. La stack K8s comprend :
*   **Base de données :** MySQL 8.4 avec persistance des données (`1Gi`).
*   **Scalabilité :** Un Horizontal Pod Autoscaler (HPA) ajuste le nombre de pods API (de 1 à 3) selon l'usage.
*   **Accès :** Le service API est en `ClusterIP` pour une sécurité accrue (non joignable directement depuis l'hôte).

**Test de l'API depuis le cluster :**
```bash
kubectl run curl-test -n lacets-connecte --rm -i --tty --image=curlimages/curl -- curl http://api.lacets-connecte.svc.cluster.local:3000/health
```

---

##  Observabilité

La surveillance est accessible immédiatement après le déploiement Ansible :

*   **Grafana :** `[http://192.168.56.20:3000](http://192.168.56.20:3000)` (Identifiants : `admin` / `admin`).
*   **Prometheus :** Accessible en local sur la VM monitoring via le port `9090`.

---

##  Commandes Utiles

*   **État des VM :** `vagrant status`
*   **Logs Kubernetes :** `kubectl get pods -n lacets-connecte`
*   **Vérification Demo :** `bash infra/scripts/check-demo.sh`
*   **Accès K3s :** `vagrant ssh k3s`

---

##  Limitations & Notes
*   **Bootstrap :** Un runner GitHub ne peut pas créer la VM sur laquelle il est censé s'enregistrer ; cette étape reste donc locale.
*   **Initialisation SQL :** Si le PVC existe déjà, le script `init-db.sql` ne sera pas rejoué. Supprimez le namespace pour une remise à zéro totale.
*   **Sécurité :** Les secrets YAML sont fournis pour la démonstration. En production, utilisez des solutions comme SealedSecrets ou Vault.
*   Instabilité du Smoke Test (--rm) : Nous avons identifié que l'option --rm de la commande kubectl run se comporte de manière imprévisible dans notre environnement virtualisé (erreur : --rm should only be used for attached containers).

Le programme ayant été lancé depuis le pc de philippe, les derniers logs(kilaw) correspondent au pc fixe de valentin mais le système à bel et bien fonctionné sur les différents pc comme en témoigne les workflows.

TP DevOps final de Lewandowski Valentin et Dumas Philippe.
