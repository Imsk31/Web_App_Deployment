#!/bin/bash
set -e

# ── Arguments ────────────────────────────────────────
IRSA_ROLE_ARN=$1
SECRET_NAME=$2
REGION=$3
DB_HOST=$4

# ── Validation ───────────────────────────────────────
if [ -z "$IRSA_ROLE_ARN" ] || [ -z "$SECRET_NAME" ] || [ -z "$REGION" ] || [ -z "$DB_HOST" ]; then
  echo "Usage: bash apply-manifests.sh <irsa-role-arn> <secret-name> <region> <db-host>"
  exit 1
fi

# ── Variables ────────────────────────────────────────
NAMESPACE="webapp"
SERVICE_ACCOUNT_NAME="backend-sa"
SECRET_STORE_NAME="aws-secretstore"
EXTERNAL_SECRET_NAME="springbackend-db-secret"
BACKEND_API_URL="/api/v1/workers"
CONFIGMAP_NAME="app-config"

# ── Apply ─────────────────────────────────────────────
echo "=== [1/8] Creating namespace ==="
kubectl apply -f manifests/namespace.yaml

echo "=== [2/8] Applying ConfigMap ==="
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${CONFIGMAP_NAME}
  namespace: ${NAMESPACE}
data:
  DB_HOST: "${DB_HOST}"
  config.json: |
    {
      "backendApiUrl": "${BACKEND_API_URL}"
    }
EOF

echo "=== [3/8] Applying ServiceAccount ==="
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE}
  annotations:
    eks.amazonaws.com/role-arn: ${IRSA_ROLE_ARN}
EOF

echo "=== [4/8] Applying SecretStore ==="
cat <<EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: ${SECRET_STORE_NAME}
  namespace: ${NAMESPACE}
spec:
  provider:
    aws:
      service: SecretsManager
      region: ${REGION}
      auth:
        jwt:
          serviceAccountRef:
            name: ${SERVICE_ACCOUNT_NAME}
EOF

echo "=== [5/8] Applying ExternalSecret ==="
cat <<EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${EXTERNAL_SECRET_NAME}
  namespace: ${NAMESPACE}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: ${SECRET_STORE_NAME}
    kind: SecretStore
  target:
    name: ${EXTERNAL_SECRET_NAME}
    creationPolicy: Owner
  data:
    - secretKey: DB_USERNAME
      remoteRef:
        key: ${SECRET_NAME}
        property: username
    - secretKey: DB_PASSWORD
      remoteRef:
        key: ${SECRET_NAME}
        property: password
EOF

echo "=== [6/8] Waiting for secret sync ==="
kubectl wait externalsecret ${EXTERNAL_SECRET_NAME} \
  -n ${NAMESPACE} \
  --for=condition=Ready \
  --timeout=120s

echo "=== [7/8] Deploying applications ==="
kubectl apply -f spring-backend/manifest/
kubectl apply -f angular-frontend/manifest/
kubectl apply -f ingress.yaml

echo "=== [8/8] Waiting for rollout ==="
kubectl rollout status deployment/backend \
  -n ${NAMESPACE} --timeout=120s
kubectl rollout status deployment/frontend \
  -n ${NAMESPACE} --timeout=120s

echo ""
echo "✅ All manifests applied successfully"
echo ""
echo "=== Pods ==="
kubectl get pods -n ${NAMESPACE}

echo ""
echo "=== ALB DNS (wait 2-3 mins) ==="
kubectl get ingress -n ${NAMESPACE}