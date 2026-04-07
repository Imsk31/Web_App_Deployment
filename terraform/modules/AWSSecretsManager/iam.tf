# -------------------------------------------------------
# IAM Role for Service Account (IRSA)
# — lets the backend pod read the secret
# -------------------------------------------------------

locals {
  oidc_provider = replace(var.oidc_issuer_url, "https://", "")
}

# -------------------------------------------------------
# IRSA Assume Role Policy Document
# -------------------------------------------------------

data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# -------------------------------------------------------
# IAM Role for IRSA
# -------------------------------------------------------

resource "aws_iam_role" "irsa_role" {
  name               = "${var.cluster_name}-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

# -------------------------------------------------------
# Secrets Manager Read Policy
# -------------------------------------------------------

resource "aws_iam_policy" "secrets_read_policy" {
  name        = "${var.cluster_name}-secrets-policy"
  description = "Allow pod to read RDS secret from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = aws_secretsmanager_secret.db_secret.arn
      }
    ]
  })
}

# -------------------------------------------------------
# Attach Secrets Read Policy to IRSA Role
# -------------------------------------------------------

resource "aws_iam_role_policy_attachment" "irsa_secrets_attach" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.secrets_read_policy.arn
}