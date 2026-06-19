variable "bastion_subnet" {}
variable "vpc_id" {}
variable "public_key" {}
variable "helmfile_version" {}
variable "kubectl_version" {}
variable "eks_cluster_arn" {}
variable "bastion_instance_type" {}
variable "project_name" {}
variable "private_key_path" {
    default = "./keys/eks_private.pem"
}
variable "efs_dns_name" {}