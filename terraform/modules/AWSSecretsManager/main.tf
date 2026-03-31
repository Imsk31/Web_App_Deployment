# -------------------------------------------------------
# 1. OIDC Provider for EKS (enables IRSA)
# -------------------------------------------------------
data "tls_certificate" "eks" {
  url = var.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = var.cluster_oidc_issuer_url

  tags = merge(
    {
      Name = "${var.cluster_name}-OIDC provider"
    },
    var.tags
  )
}

# -------------------------------------------------------
# Secrets Manager — store RDS credentials
# -------------------------------------------------------
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = var.secret_name
  description             = "RDS credentials"
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    {
      Name = "${var.identifier}-db-secret"
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}