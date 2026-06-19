variable "project_name" {}
variable "oidc_url" {}
variable "alias" {
  default = "eks-monitoring"
}
variable "prometheus_agent_sa" {
  default = "monitoring:amp-iamproxy-ingest-service-account"
}