variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "The name for the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to the EC2 instance"
  type        = map(string)

}
variable "key_name" {
  description = "The name of the key pair"
  type        = string

}
variable "public_key_path" {
  description = "The path to the public key file for the key pair"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the EC2 instance"
  type        = list(string)
}

variable "volume_size" {
  description = "The size of the root volume"
  type        = number
}

variable "volume_type" {
  description = "The type of the root volume"
  type        = string
}

variable "user_data" {
  description = "User data script to initialize the EC2 instance"
  type        = string
}