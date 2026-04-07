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
    security_groups = var.source_security_group_ids
  }

  #   # Allow access from local machine (dev only)
  # dynamic "ingress" {
  #   for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
  #   content {
  #     description = "Allow DB access from local machine"
  #     from_port   = 3306
  #     to_port     = 3306
  #     protocol    = "tcp"
  #     cidr_blocks = var.allowed_cidr_blocks
  #   }
  # }

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