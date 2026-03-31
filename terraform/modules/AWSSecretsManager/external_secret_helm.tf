# -------------------------------------------------------
# Install External Secrets Operator via Helm
# -------------------------------------------------------
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  version          = "0.9.13"
  create_namespace = true

  set = [
    {
      name  = "installCRDs"
      value = "true"
    },
    {
      name  = "webhook.port"
      value = "9443"
    }
  ]
}