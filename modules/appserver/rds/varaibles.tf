
## Common varaibles 
variable "mysql_subnets" {}

variable "rds_access_sg" {
  default = []
}

variable "vpc_id" {}

variable "kms_deletion_window_in_days" {
  default = 7
}

variable "rds_port" {}

variable "project_name" {}

variable "engine_version" {
  default = "8.0"
}

variable "backup_retention_period" {
  default = "7"
}

variable "parameter_group_name" {
  default = "default.mysql8.0"
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

variable "monitoring_interval" {}

variable "mysql_rds_username" {}



### IRIX varaibles
variable "irix_rds_identifier" {}

variable "irix_allocated_storage" {}

variable "irix_instance_class" {}

variable "irix_backup_retention_period" {
  default = "7"
}

variable "irix_deletion_protection" {
  default = true
}

variable "irix_backup_window" {
  default = "04:00-05:00"
}

variable "irix_performance_insights_enabled" {
  default = true
}

variable "irix_storage_type" {}

variable "irix_iops" {}

variable "irix_max_allocated_storage" {}

variable "irix_mysql_rds_secret_name" {}


### NOVA varaibles
variable "nova_rds_identifier" {}

variable "nova_allocated_storage" {}

variable "nova_instance_class" {}

variable "nova_backup_retention_period" {
  default = "7"
}

variable "nova_deletion_protection" {
  default = true
}

variable "nova_backup_window" {
  default = "04:00-05:00"
}

variable "nova_performance_insights_enabled" {
  default = true
}

variable "nova_storage_type" {}

variable "nova_iops" {}

variable "nova_max_allocated_storage" {}

variable "nova_mysql_rds_secret_name" {}



### TINA varaibles
variable "tina_rds_identifier" {}

variable "tina_allocated_storage" {}

variable "tina_instance_class" {}

variable "tina_backup_retention_period" {
  default = "7"
}

variable "tina_deletion_protection" {
  default = true
}

variable "tina_backup_window" {
  default = "04:00-05:00"
}

variable "tina_performance_insights_enabled" {
  default = true
}

variable "tina_storage_type" {}

variable "tina_iops" {}

variable "tina_max_allocated_storage" {}

variable "tina_mysql_rds_secret_name" {}