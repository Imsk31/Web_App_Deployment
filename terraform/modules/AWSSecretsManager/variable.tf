variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "secret_name" {
  description = "Secrets Manager secret name"
  type        = string
}

variable "namespace" {
  description = "K8s namespace for backend"
  type        = string
}

variable "service_account_name" {
  description = "K8s service account name to annotate with IRSA role"
  type        = string
}

variable "identifier" {
  description = "RDS Instance Identifier"
  type = string
  default = "null"
}

variable "recovery_window_in_days" {
  description = "Recovery window in days"
  type = number
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}