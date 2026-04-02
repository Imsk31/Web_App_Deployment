output "lb_controller_role_arn" {
  description = "IRSA role ARN for AWS LB Controller"
  value       = aws_iam_role.lb_controller_role.arn
}
