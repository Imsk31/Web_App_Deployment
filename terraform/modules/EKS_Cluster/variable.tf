variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes in the node group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes in the node group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes in the node group"
  type        = number
}

variable "instance_type" {
  description = "The EC2 instance type for the worker nodes"
  type        = string
}

variable "admin_sg_id" {
  description = "The security group ID for the admin host"
  type        = string
  default = null
}

variable "endpoint_public_access" {
  description = "Whether to enable public access to the EKS API endpoint"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Whether to enable private access to the EKS API endpoint"
  type        = bool
}