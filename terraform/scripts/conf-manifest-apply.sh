#!/bin/bash
set -e

# ── Arguments ────────────────────────────────────────
IRSA_ROLE_ARN=$1
SECRET_NAME=$2
REGION=$3
RDS_ENDPOINT=$4

# ── Validation ───────────────────────────────────────
if [ -z "$IRSA_ROLE_ARN" ] || [ -z "$SECRET_NAME" ] || [ -z "$REGION" ] || [ -z "$RDS_ENDPOINT" ]; then
  echo "Usage: bash conf-manifest-apply.sh <irsa_role_arn> <secret_name> <region> <RDS_Endpoint>"
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
echo "=== [1/6] Creating namespace ==="
kubectl apply -f manifests/namespace.yaml

echo "=== [2/6] Applying ConfigMap ==="
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${CONFIGMAP_NAME}
  namespace: ${NAMESPACE}
data:
  DB_HOST: "${RDS_ENDPOINT}"
  config.json: |
    {
      "backendApiUrl": "${BACKEND_API_URL}"
    }
EOF

echo "=== [3/6] Applying ServiceAccount ==="
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE}
  annotations:
    eks.amazonaws.com/role-arn: ${IRSA_ROLE_ARN}
EOF

echo "=== [4/6] Applying SecretStore ==="
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

echo "=== [5/6] Applying ExternalSecret ==="
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

echo "=== [6/6] Waiting for secret sync ==="
kubectl wait externalsecret ${EXTERNAL_SECRET_NAME} \
  -n ${NAMESPACE} \
  --for=condition=Ready \
  --timeout=120s

echo ""
echo "All cluster configurationmanifests applied successfully"

echo "Checking ConfigMap status:"
kubectl get configmap ${CONFIGMAP_NAME} -n ${NAMESPACE} -o yaml

echo "Checking ExternalSecret status:"
kubectl get externalsecret ${EXTERNAL_SECRET_NAME} -n ${NAMESPACE} -o yaml

echo "Checking Secret status:"
kubectl get secret ${EXTERNAL_SECRET_NAME} -n ${NAMESPACE} -o yaml

echo "Checking ServiceAccount status:"
kubectl get serviceaccount ${SERVICE_ACCOUNT_NAME} -n ${NAMESPACE} -o yaml

