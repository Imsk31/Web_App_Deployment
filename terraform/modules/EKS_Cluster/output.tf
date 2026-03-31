output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "worker_security_group_id" {
  value = aws_security_group.eks_worker_sg.id
}

output "cluster_oidc_issuer_url" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}