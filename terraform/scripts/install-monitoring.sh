#!/bin/bash
set -e

# ── Variables ────────────────────────────────────────
NAMESPACE="monitoring"

echo "=== [1/2] Adding Prometheus Helm repo ==="
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
helm repo update

echo "=== [2/2] Installing Prometheus + Grafana ==="
helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace ${NAMESPACE} \
  --set grafana.enabled=true \
  --set grafana.adminPassword="admin123" \   #change this password in production and consider using a secret
  --set alertmanager.enabled=true \
  --set nodeExporter.enabled=true \
  --set kubeStateMetrics.enabled=true \
  --wait \
  --timeout 300s

echo "=== Verifying Prometheus + Grafana ==="
kubectl get pods -n ${NAMESPACE} | grep kube-prometheus-stack

echo ""
echo "Prometheus + Grafana installed successfully"
