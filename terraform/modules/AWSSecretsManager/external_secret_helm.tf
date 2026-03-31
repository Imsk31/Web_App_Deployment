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
  wait = true
  timeout = 480

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

  lifecycle {
  ignore_changes = [
    set
  ]
}
}