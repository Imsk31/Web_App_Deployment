variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames for the VPC"
  type        = bool
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support for the VPC"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
}

variable "connectivity_type" {
  description = "Connectivity type for the NAT gateway (e.g., public or private)"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "The name for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair"
  type        = string

}
variable "public_key_path" {
  description = "The path to the public key file for the key pair"
  type        = string
}

variable "volume_size" {
  description = "The size of the root volume"
  type        = number
}

variable "volume_type" {
  description = "The type of the root volume"
  type        = string
}

variable "identifier" {
  description = "RDS identifier"
  type = string
}

variable "rds_engine" {
  description = "RDS engine (e.g., mysql, postgres)"
  type = string
}

variable "engine_version" {
  description = "RDS engine version"
  type = string
}

variable "instance_class" {
  description = "RDS instance class (e.g., db.t3.micro)"
  type = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type = number
}

variable "storage_type" {
  description = "Storage type (e.g., gp2, io1)"
  type = string
}

variable "storage_encrypted" {
  description = "Whether to encrypt storage"
  type = bool
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment"
  type = bool
}
variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type = bool
}

variable "username" {
  description = "Master username for the RDS instance"
  type = string
}

variable "password" {
  description = "Master password for the RDS instance"
  type = string
  sensitive = true
}

variable "password_wo_version" {
  description = "Master password for the RDS instance without version"
  type = string
  sensitive = true
}

variable "snapshot_identifier" {
  description = "Snapshot identifier to restore from"
  type = string
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on deletion"
  type = bool
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type = bool
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type = string 
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string 
}

variable "eks_instance_type" {
  description = "EC2 instance type for cluster nodes"
  type = string
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

variable "secret_name" {
  description = "Secrets Manager secret name"
  type        = string
}

variable "secrets_manager_namespace" {
  description = "K8s namespace for Secrets Manager"
  type        = string
}

variable "secrets_manager_service_account_name" {
  description = "K8s service account name for Secrets Manager"
  type        = string
}

variable "recovery_window_in_days" {
  description = "Recovery window in days"
  type = number
}

variable "aws_lb_controller_namespace" {
  description = "K8s namespace for AWS Load Balancer Controller"
  type        = string
}

variable "aws_lb_controller_service_account_name" {
  description = "K8s service account name for AWS Load Balancer Controller"
  type        = string
}

variable "endpoint_public_access" {
  description = "Whether to enable public access to the EKS API endpoint"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Whether to enable private access to the EKS API endpoint"
  type        = bool
}

# variable "environment" {
#   description = "Deployment environment (e.g., dev, prod)"
#   type = string
# }