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

output "vpc_security_group_ids" {
  value = data.aws_security_groups.all.ids
}

output "RDS_Endpoint" {
  value = module.RDS.RDS_Endpoint
}

output "cluster_name" {
  value = module.EKS.cluster_name
}

output "cluster_endpoint" {
  value = module.EKS.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.EKS.cluster_security_group_id
}

output "worker_security_group_id" {
  value = module.EKS.worker_security_group_id
}