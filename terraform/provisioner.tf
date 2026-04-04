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
      bash ${path.module}/scripts/install-eso.sh \
        ${var.cluster_name} \
        ${var.region} && \
      bash ${path.module}/scripts/conf-manifest-apply.sh \
        $(terraform output -raw irsa_role_arn) \
        $(terraform output -raw secret_name) \
        ${var.region} \
        $(terraform output -raw RDS_Endpoint | cut -d: -f1) && \
      bash ${path.module}/scripts/monitoring.sh \
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