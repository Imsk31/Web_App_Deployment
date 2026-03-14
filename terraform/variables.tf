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

# variable "availability_zones" {
#   description = "Availability zones for the subnets"
#   type        = list(string)
# }

variable "connectivity_type" {
  description = "Connectivity type for the NAT gateway (e.g., public or private)"
  type        = string
}
