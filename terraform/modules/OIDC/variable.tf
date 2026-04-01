variable "cluster_oidc_issuer_url" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}