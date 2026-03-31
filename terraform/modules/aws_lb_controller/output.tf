output "lb_controller_role_arn" {
  description = "IRSA role ARN for AWS LB Controller"
  value       = aws_iam_role.lb_controller_role.arn
}

output "lb_controller_role_name" {
  description = "IRSA role name for AWS LB Controller"
  value       = aws_iam_role.lb_controller_role.name
}