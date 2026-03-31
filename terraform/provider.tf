provider "aws" {
  region = var.region
}

# Required for ESO Helm install
provider "helm" {
  kubernetes = {
    host                   = module.EKS.cluster_endpoint
    cluster_ca_certificate = base64decode(module.EKS.cluster_ca_certificate)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}