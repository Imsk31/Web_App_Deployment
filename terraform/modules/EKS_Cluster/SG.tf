#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# EKS Cluster Security Groups. This code defines two security groups for the EKS cluster: one for the cluster itself and another for the worker nodes.
# The cluster security group allows communication from the worker nodes to the cluster API server on port 443, while the worker security group allows communication between worker nodes and with the cluster API server on a range of ports. Both security groups allow all outbound traffic. 
# The security groups are tagged with the cluster name and any additional tags provided in the variables.
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "${var.cluster_name}-cluster-sg"
    },
    var.tags
  )
}

# -------------------------------------------------------
# Allow Admin (EC2 / your machine) → EKS API (kubectl)
# -------------------------------------------------------

resource "aws_security_group_rule" "admin_to_eks" {
  type                     = "ingress"
  description              = "Allow admin to access EKS API"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"

  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = var.admin_sg_id
}

# -------------------------------------------------------
# INTERNAL CLUSTER COMMUNICATION (VERY IMPORTANT)
# -------------------------------------------------------

resource "aws_security_group_rule" "cluster_internal" {
  type              = "ingress"
  description       = "Allow all traffic within cluster"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"

  security_group_id = aws_security_group.eks_cluster_sg.id
  self              = true
}

# -------------------------------------------------------
# ALLOW NODE → CONTROL PLANE (HTTPS)
# -------------------------------------------------------

resource "aws_security_group_rule" "worker_to_cluster_api" {
  type              = "ingress"
  description       = "Worker nodes to EKS API"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"

  security_group_id = aws_security_group.eks_cluster_sg.id
  self              = true
}

# -------------------------------------------------------
# OUTBOUND (MANDATORY)
# -------------------------------------------------------

resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  security_group_id = aws_security_group.eks_cluster_sg.id
}