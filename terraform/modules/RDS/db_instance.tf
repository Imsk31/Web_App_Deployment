#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform module for creating an RDS instance with a subnet group
# This module allows you to create an RDS instance with specified configurations, including engine type, version, instance class, storage options, and security group associations.
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


resource "aws_db_instance" "main" {

  engine                = var.rds_engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  
  multi_az                = var.multi_az
  publicly_accessible     = var.publicly_accessible
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  identifier              = var.identifier
  db_name = var.db_name   
  
  username = var.username

  password_wo         = var.password
  password_wo_version = var.password_wo_version
  
  snapshot_identifier = var.snapshot_identifier
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

    tags = merge(
    {
      Name = "${var.identifier}-instance"
    },
    var.tags
  )
}

#----------------------------------------------------------------------------------------------------------------
# Terraform module for creating a DB subnet group for RDS
# This module creates a DB subnet group that can be associated with an RDS instance. 
# It takes a list of subnet IDs and tags as input and creates a subnet group that can be used to specify the subnets in which the RDS instance will be deployed.
#----------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {

  name        = var.db_subnet_group_name
  subnet_ids  = var.subnet_ids

    tags = merge(
    {
      Name = "${var.db_subnet_group_name}-subnet-group"
    },
    var.tags
  )
}
