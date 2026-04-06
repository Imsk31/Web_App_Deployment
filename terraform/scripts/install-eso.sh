#!/bin/bash
set -e

CLUSTER_NAME=$1
REGION=$2

# ── Variables ────────────────────────────────────────
NAMESPACE="webapp"

if [ -z "$CLUSTER_NAME" ] || [ -z "$REGION" ]; then
  echo "Usage: bash install-eso.sh <cluster-name> <region>"
  exit 1
fi

echo "=== [1/2] Checking LB Controller is running ==="
LB_READY=$(kubectl get pods -n kube-system \
  --selector=app.kubernetes.io/name=aws-load-balancer-controller \
  --field-selector=status.phase=Running \
  --no-headers 2>/dev/null | wc -l)

if [ "$LB_READY" -eq "0" ]; then
  echo "LB Controller is not running!"
  echo "   Run install-lb-controller.sh first"
  exit 1
fi

echo "LB Controller is running — proceeding"

echo "=== [2/2] Installing External Secrets Operator via Helm ==="
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm upgrade --install external-secrets \
  external-secrets/external-secrets \
  --namespace ${NAMESPACE} \
  --set installCRDs=true \
  --version 0.9.13 \
  --wait \
  --timeout 300s

echo ""
echo "=== Verifying ESO ==="
kubectl get pods -n ${NAMESPACE}
echo ""
echo "ESO installed successfully"