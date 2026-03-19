output "aws_instance_id" {
  value = aws_instance.main.id
}

output "aws_instance_public_ip" {
  value = aws_instance.main.public_ip
}
