variable "mysql_subnets" {}
variable "rds_access_sg" {
  default = []
}
variable "vpc_id" {}
variable "kms_deletion_window_in_days" {
  default = 7
}
variable "identifier" {}
variable "prod_rds_identifier" {}
variable "rds_port" {}
variable "project_name" {}
variable "allocated_storage" {}
variable "prod_allocated_storage" {}
variable "engine_version" {
  default = "8.0"
}
variable "instance_class" {}
variable "prod_instance_class" {}
variable "backup_retention_period" {
  default = "7"
}
variable "prod_backup_retention_period" {
  default = "7"
}
variable "deletion_protection" {
  default = true
}
variable "prod_deletion_protection" {
  default = true
}
variable "parameter_group_name" {
  default = "default.mysql8.0"
}
variable "backup_window" {
  default = "04:00-05:00"
}
variable "prod_backup_window" {
  default = "04:00-05:00"
}
variable "performance_insights_enabled" {
  default = true
}
variable "prod_performance_insights_enabled" {
  default = true
}
variable "auto_minor_version_upgrade" {
  default = false
}
variable "multi_az" {
  default = false
}
variable "replicate_source_db" {
  default = null
}
variable "engine" {
  default = null
}

variable "db_source_ip" {
  type = list(string)
}

variable "storage_type" {
  
}
variable "prod_storage_type" {
  
}
variable "iops" {
  
}
variable "prod_iops" {
  
}
variable "max_allocated_storage" {
  
}
variable "prod_max_allocated_storage" {
  
}
variable "monitoring_interval" {
  
}


variable "mysql_rds_secret_name" {
  
}
variable "mysql_rds_username" {
  
}