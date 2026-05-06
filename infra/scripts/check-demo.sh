#!/usr/bin/env bash
set -euo pipefail

kubectl get nodes
kubectl get pods -n lacets-connecte
kubectl get hpa -n lacets-connecte
kubectl -n lacets-connecte delete pod curl-test --ignore-not-found
kubectl run curl-test \
  --namespace lacets-connecte \
  --rm \
  --restart Never \
  --image curlimages/curl:8.11.1 \
  --command -- curl -fsS http://api.lacets-connecte.svc.cluster.local:3000/health
