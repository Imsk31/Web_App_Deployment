# -------------------------------------------------------
# VPC Module - Creates VPC, subnets, and networking
# -------------------------------------------------------
module "vpc" {
  source                = "./modules/vpc"
  vpc_name              = var.vpc_name
  vpc_cidr              = var.vpc_cidr
  region                = var.region
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  connectivity_type     = var.connectivity_type
  enable_dns_support    = var.enable_dns_support
  enable_dns_hostnames  = var.enable_dns_hostnames
  tags                  = var.tags
}

# -------------------------------------------------------
# EC2 Module - Provisions EC2 instance
# -------------------------------------------------------
module "ec2" {
  source              = "./modules/ec2"
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  subnet_id           = module.vpc.public_subnet_ids[0]
  instance_name       = var.instance_name
  key_name            = var.key_name
  public_key_path     = var.public_key_path
  security_group_ids  = [aws_security_group.ec2_sg.id]
  volume_size         = var.volume_size
  volume_type         = var.volume_type
  tags                = var.tags
}

# data "http" "my_ip" {
#   url = "https://ifconfig.me/ip"
# }

# -------------------------------------------------------
# RDS Module - Creates RDS database instance
# -------------------------------------------------------
module "RDS" {
  source = "./modules/RDS"

  identifier        = var.identifier
  rds_engine        = var.rds_engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  vpc_id                    = module.vpc.vpc_id
  source_security_group_ids = [aws_security_group.ec2_sg.id, module.EKS.node_security_group_id]
  # allowed_cidr_blocks       = var.environment == "dev" ? ["${trimspace(data.http.my_ip.response_body)}/32"] : []

  multi_az                     = var.multi_az
  publicly_accessible          = var.publicly_accessible
  subnet_ids                   = module.vpc.private_subnet_ids
  # subnet_ids = var.environment == "dev" ? module.vpc.public_subnet_ids : module.vpc.private_subnet_ids
  db_subnet_group_name         = var.db_subnet_group_name


  username             = var.username
  password             = var.password
  password_wo_version  = var.password_wo_version

  snapshot_identifier = var.snapshot_identifier
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  tags = var.tags
}

# -------------------------------------------------------
# EKS Module - Creates EKS cluster and node group
# -------------------------------------------------------
module "EKS" {
  source = "./modules/EKS_Cluster"

  cluster_name            = var.cluster_name
  vpc_id                  = module.vpc.vpc_id
  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access

  private_subnet_ids  = module.vpc.private_subnet_ids
  admin_sg_id         = aws_security_group.ec2_sg.id

  desired_size    = var.desired_size
  max_size        = var.max_size
  min_size        = var.min_size
  instance_type   = var.eks_instance_type

  tags = var.tags
}

# -------------------------------------------------------
# OIDC Module - Sets up OIDC provider for EKS
# -------------------------------------------------------
module "oidc" {
  source                  = "./modules/OIDC"
  cluster_oidc_issuer_url = module.EKS.cluster_oidc_issuer_url

tags = var.tags
}

# -------------------------------------------------------
# AWS Load Balancer Controller Module - Deploys ALB controller
# -------------------------------------------------------
module "aws_lb_controller" {
  source = "./modules/aws_lb_controller"

  cluster_name         = var.cluster_name
  oidc_provider_arn    = module.oidc.oidc_provider_arn
  oidc_issuer_url      = module.oidc.oidc_issuer_url
  namespace            = var.aws_lb_controller_namespace
  service_account_name = var.aws_lb_controller_service_account_name

  depends_on = [module.EKS, module.oidc]

  tags = var.tags
}

# -------------------------------------------------------
# Secrets Manager Module - Manages database secrets
# -------------------------------------------------------
module "secrets_manager" {
  source = "./modules/AWSSecretsManager"

  cluster_name            = var.cluster_name
  oidc_issuer_url         = module.oidc.oidc_issuer_url
  oidc_provider_arn       = module.oidc.oidc_provider_arn
  recovery_window_in_days = var.recovery_window_in_days
  db_username             = var.username
  db_password             = var.password
  secret_name             = var.secret_name
  namespace               = var.secrets_manager_namespace
  service_account_name    = var.secrets_manager_service_account_name

  depends_on = [module.EKS, module.oidc, module.aws_lb_controller]

  tags = var.tags
}