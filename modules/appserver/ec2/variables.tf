variable "public_key" {}
variable "project_name" {}
variable "appserver_subnet" {}
variable "vpc_id" {}
variable "vm_configs" {
  description = "Configuration for each VM"
  type = map(object({
    instance_type = string
    disk_size     = number
    ingress_rules = list(object({
      port        = number
      cidr_blocks = list(string)
    }))
  }))
  default = {}
}
