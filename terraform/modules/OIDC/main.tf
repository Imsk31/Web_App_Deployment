# -------------------------------------------------------
# OIDC Provider for EKS
# — configures AWS IAM OIDC trust for the EKS cluster
# -------------------------------------------------------

# Fetches the TLS certificate fingerprint for the cluster OIDC issuer,
data "tls_certificate" "eks" {
  url = var.cluster_oidc_issuer_url
}

# creates the IAM OpenID Connect provider using that issuer URL and thumbprint.
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = var.cluster_oidc_issuer_url

  tags = var.tags
}