variable "cluster_name" {}
variable "cluster_version" {}
variable "private_subnets" {}
variable "eks_api_access" {}
variable "vpc_id" {}
variable "project_name" {}
variable "argo_workflows_sa" {
  default = null
}
variable "service_ipv4_cidr" {
  default = "10.244.240.0/20" 
}
variable "alb_controller_sa" {
  default = "kube-system:aws-load-balancer-controller"
}