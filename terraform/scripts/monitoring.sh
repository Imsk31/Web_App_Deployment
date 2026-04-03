#!/bin/bash
set -e

GRAFANA_PASSWORD=$1

if [ -z "$GRAFANA_PASSWORD" ]; then
  echo "Usage: bash install-monitoring.sh <grafana-password>"
  exit 1
fi

echo "=== [1/2] Adding Prometheus Helm repo ==="
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
helm repo update

echo "=== [2/2] Installing Prometheus + Grafana ==="
helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=$GRAFANA_PASSWORD \
  --set grafana.enabled=true \
  --set alertmanager.enabled=true \
  --set nodeExporter.enabled=true \
  --set kubeStateMetrics.enabled=true \
  --wait \
  --timeout 300s

echo ""
echo "Prometheus + Grafana installed successfully"
echo "Run: kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring"