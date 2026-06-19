variable "region_azs" {}
variable "num_public_subnets" {}
variable "num_private_subnets" {}
variable "vpc_cidr" {}
variable "project_name" {}
variable "single_nat_gateway" {
  default = false
}
variable "create_vpc_flow_log" {
  default = false
}
variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}
variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}
# variable "private_nat_eni_ids" {
#   type = list(string)
# }
