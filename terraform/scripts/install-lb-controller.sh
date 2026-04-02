#!/bin/bash
set -e

CLUSTER_NAME=$1
REGION=$2
LB_ROLE_ARN=$3

if [ -z "$CLUSTER_NAME" ] || [ -z "$REGION" ] || [ -z "$LB_ROLE_ARN" ]; then
  echo "Usage: bash install-lb-controller.sh <cluster-name> <region> <lb-role-arn>"
  exit 1
fi

echo "=== [1/3] Configuring kubectl ==="
aws eks update-kubeconfig \
  --region $REGION \
  --name $CLUSTER_NAME

echo "=== [2/3] Creating LB Controller Service Account ==="
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: ${LB_ROLE_ARN}
EOF

echo "=== [3/3] Installing AWS Load Balancer Controller via Helm ==="
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --wait \
  --timeout 120s

echo ""
echo "=== Verifying LB Controller ==="
kubectl get pods -n kube-system | grep aws-load-balancer
echo ""
echo "LB Controller installed successfully"