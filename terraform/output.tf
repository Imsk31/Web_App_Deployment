output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "aws_instance_id" {
  value = module.ec2.aws_instance_id
}

output "aws_instance_public_ip" {
  value = module.ec2.aws_instance_public_ip
}

output "security_group_id" {
  value = aws_security_group.main.id
}
