# -------------------------------------------------------
# Elastic IP for the EC2 instance
# -------------------------------------------------------
resource "aws_eip" "ec2_eip" {
  instance = aws_instance.main.id
  domain = "vpc"
}

# -------------------------------------------------------
# SSH Key Pair for accessing the instance
# -------------------------------------------------------
resource "aws_key_pair" "key_pair" {
  key_name    = var.key_name
  public_key  = file(var.public_key_path)
}

# -------------------------------------------------------
# Main EC2 instance
# -------------------------------------------------------
resource "aws_instance" "main" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = var.security_group_ids
  key_name = var.key_name
  user_data =  file("${path.module}/user-data.sh")

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = merge(
    {
      "Name" = var.instance_name
    },
    var.tags
  )
}
