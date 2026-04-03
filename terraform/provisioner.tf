resource "null_resource" "cluster_setup" {
  triggers = {
    cluster_name = var.cluster_name
    region       = var.region
  }

  provisioner "local-exec" {
    command = <<-EOT
      bash ${path.module}/scripts/install-lb-controller.sh \
        ${var.cluster_name} \
        ${var.region} \
        ${module.aws_lb_controller.lb_controller_role_arn} \
        ${module.vpc.vpc_id} && \
      echo "Waiting for LB controller to be ready..." && \
      aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name} && \
      kubectl wait deployment/aws-load-balancer-controller \
        -n kube-system \
        --for=condition=Available \
        --timeout=300s && \
      bash ${path.module}/scripts/install-eso.sh \
        ${var.cluster_name} \
        ${var.region}\
      bash ${path.module}/scripts/install-monitoring.sh \
        ${var.cluster_name} \
        ${var.region} \
        ${var.grafana_password}
    EOT
  }

  depends_on = [
    module.EKS,
    module.oidc,
    module.aws_lb_controller,
    module.secrets_manager
  ]
}