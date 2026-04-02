variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN from EKS cluster"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from EKS cluster"
  type        = string
}

variable "namespace" {
  description = "K8s namespace for LB controller"
  type        = string
}

variable "service_account_name" {
  description = "K8s service account name for LB controller"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}