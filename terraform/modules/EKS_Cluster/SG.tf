#####################################################################################################################################################################################################################
# EKS Cluster Security Groups. This code defines two security groups for the EKS cluster: one for the cluster itself and another for the worker nodes.
# The cluster security group allows communication from the worker nodes to the cluster API server on port 443, while the worker security group allows communication between worker nodes and with the cluster API server on a range of ports. Both security groups allow all outbound traffic. 
#The security groups are tagged with the cluster name and any additional tags provided in the variables.
#####################################################################################################################################################################################################################

# Cluster SG
resource "aws_security_group" "eks_cluster_sg" {
  name   = "${var.cluster_name}-cluster-sg"
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_name}-cluster-sg"
    },
    var.tags
  )
}

# clsuetr to worker communication
resource "aws_security_group_rule" "worker_to_cluster" {
  type                     = "ingress"
  description              = "Worker nodes EKS API server"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"

  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_worker_sg.id
}

# Allow all outbound traffic from cluster SG
resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  security_group_id = aws_security_group.eks_cluster_sg.id
}

# Worker to cluster communication
resource "aws_security_group" "eks_worker_sg" {
  name   = "${var.cluster_name}-worker-sg"
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_name}-worker-sg"
    },
    var.tags
  )
}

# Allow worker nodes to communicate with the cluster API server
resource "aws_security_group_rule" "cluster_to_worker" {
  type                     = "ingress"
  description              = "Allow worker nodes to communicate with the cluster API server"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"

  security_group_id        = aws_security_group.eks_worker_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
}

# Allow worker nodes to communicate with each other
resource "aws_security_group_rule" "worker_to_worker" {
  type              = "ingress"
  description       = "Worker nodes internal communication"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true

  security_group_id = aws_security_group.eks_worker_sg.id
}

# Allow all outbound traffic from worker SG
resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  security_group_id = aws_security_group.eks_worker_sg.id
}