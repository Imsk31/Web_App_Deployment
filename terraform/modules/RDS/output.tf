output "RDS_Endpoint" {
  description = "The endpoint of the RDS instance"
  value = aws_db_instance.main.endpoint
}
output "rds_sg_id" {
  description = "The security group ID of the RDS instance"
  value = aws_security_group.rds_sg.id
}