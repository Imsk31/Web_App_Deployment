############################################################################################
# Terraform module for creating an Private EKS cluster and node group
# This module creates an EKS cluster with a specified name, VPC, and private subnets. 
# It also sets up the necessary IAM roles and policies for the cluster and worker nodes. 
# The node group is configured with desired, maximum, and minimum sizes, as well as the instance types for the worker nodes. 
# The module allows for tagging of resources for better organization and management.
############################################################################################

# -------------------------------------------------------
# EKS Cluster Configuration
# -------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  enabled_cluster_log_types = [ "api", "audit", "authenticator", "controllerManager", "scheduler" ]

  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_public_access = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  depends_on = [ aws_iam_role_policy_attachment.eks_cluster_role_attachment ]

  tags = merge(
    {
      Name = var.cluster_name
    },
    var.tags
  )
}

# -------------------------------------------------------
# EKS Node Group Configuration
# -------------------------------------------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn

  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }

  instance_types = [ var.instance_type ]
  
  depends_on = [ aws_eks_cluster.main
    , aws_iam_role_policy_attachment.worker_node_policy_attachment
    , aws_iam_role_policy_attachment.cni_policy_attachment
    , aws_iam_role_policy_attachment.ecr_policy_attachment
    , aws_iam_role_policy_attachment.ebs_csi_policy_attachment
  ]
}