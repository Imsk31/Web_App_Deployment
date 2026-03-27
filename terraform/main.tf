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

resource "aws_security_group" "ec2_sg" {
  name        = "${var.instance_name}-sg"
  description = "EC2 security group"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow DataBase access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }

  tags = merge(
    {
      Name = "${var.instance_name}-sg"
    },
    var.tags
  )
}

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

module "RDS" {
  source = "./modules/RDS"

  identifier        = var.identifier
  rds_engine        = var.rds_engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  vpc_id                 = module.vpc.vpc_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  subnet_ids             = module.vpc.private_subnet_ids
  db_subnet_group_name   = var.db_subnet_group_name


  username             = var.username
  password             = var.password
  password_wo_version  = var.password_wo_version

  snapshot_identifier = var.snapshot_identifier
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  tags = var.tags
}

module "EKS" {
  source = "./modules/EKS_Cluster"

  cluster_name        = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  admin_sg_id         = aws_security_group.ec2_sg.id

  desired_size    = var.desired_size
  max_size        = var.max_size
  min_size        = var.min_size
  instance_type   = var.eks_instance_type

  tags = var.tags
}