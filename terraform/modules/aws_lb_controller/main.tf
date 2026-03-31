# -------------------------------------------------------
# Fetch official AWS LB Controller IAM policy from AWS
# -------------------------------------------------------
data "http" "lb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lb_controller_policy" {
  name        = "${var.cluster_name}-lb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.http.lb_controller_policy.response_body

  tags = var.tags
}

# -------------------------------------------------------
# IRSA trust policy
# -------------------------------------------------------
locals {
  oidc_provider = replace(var.oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "lb_controller_assume_role" {
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
# IRSA Role
# -------------------------------------------------------
resource "aws_iam_role" "lb_controller_role" {
  name               = "${var.cluster_name}-lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}