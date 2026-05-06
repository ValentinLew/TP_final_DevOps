#!/usr/bin/env bash
set -euo pipefail

kubectl get nodes
kubectl get pods -n lacets_connecte
kubectl get hpa -n lacets_connecte
kubectl -n lacets_connecte delete pod curl-test --ignore-not-found
kubectl run curl-test \
  --namespace lacets_connecte \
  --rm \
  --restart Never \
  --image curlimages/curl:8.11.1 \
  --command -- curl -fsS http://api.lacets_connecte.svc.cluster.local:3000/health
