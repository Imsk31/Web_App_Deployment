output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_secret.name
}

output "irsa_role_arn" {
  description = "IAM Role ARN to annotate on the K8s service account"
  value       = aws_iam_role.irsa_role.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = var.oidc_provider_arn
}