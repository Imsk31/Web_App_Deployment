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
variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs for the RDS instance"
  type = list(string)
}
variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type = list(string)
}
variable "tags" {
  description = "Tags to apply to the RDS instance"
  type = map(string)
  default = {}
}