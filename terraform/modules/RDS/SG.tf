#---------------------------------------------------------------
# Security Group for RDS Instance
#---------------------------------------------------------------


resource "aws_security_group" "rds_sg" {
  name        = "${var.identifier}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow DataBase access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = var.vpc_security_group_ids
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
      Name = "${var.identifier}-rds-sg"
    },
    var.tags
  )
}