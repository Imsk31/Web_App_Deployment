# -------------------------------------------------------
# IAM Role for Service Account (IRSA)
# — lets the backend pod read the secret
# -------------------------------------------------------
locals {
  oidc_provider = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}

#
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
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

resource "aws_iam_role" "irsa_role" {
  name               = "${var.cluster_name}-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

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

resource "aws_iam_role_policy_attachment" "irsa_secrets_attach" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.secrets_read_policy.arn
}