

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "project_name" {
  description = "Project of infra"
  type        = string
}
variable "environment" {
  description = "Environmen Name"
  type        = string
}

variable "vpc_id" {
  
}

variable "efs_sg" {
  description = "Allowed NFS access"
  type        = map(any)
}