variable "region_azs" {}
variable "num_public_subnets" {}
variable "num_private_subnets" {}
variable "cluster_name" {}
variable "cluster_version" {}
variable "vpc_cidr" {}
variable "public_key" {}
variable "helmfile_version" {}
variable "kubectl_version" {}
variable "bastion_instance_type" {}
variable "project_name" {}
variable "common_tags" {}
variable "rds_identifier" {}
variable "nodegroup_ami_type" {}
variable "profile" {}
variable "aws_region" {}
variable "environment" {

}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

# variable "private_nat_eni_ids" {
#   type = list(string)
#   description = "List of NAT ENI IDs"
#   default     = [] # ✅ Prevents Terraform from pausing and asking "Enter a value:"
# }


variable "efs_sg" {

}
variable "db_source_ip" {
  type = list(string)
}
variable "disk_size" {
  type = string
}


variable "special_node_group_name" {
  type = string
}


variable "special_nodes_instance_types" {
  default = ["t3.large"]
}

variable "special_disk_size" {
  type = number
}

variable "special_taints" {
  default = []
}


variable "monitoring_node_group_name" {
  type = string
}


variable "monitoring_nodes_instance_types" {
  default = ["t3.medium"]
}

variable "monitoring_disk_size" {
  type = number
}

variable "monitoring_taints" {
  default = []
}

variable "prod_node_group_name" {
  type = string
}
variable "queue_worker_prod_node_group_name" {
  type = string
}

variable "prod_nodes_instance_types" {
  default = ["t3.medium"]
}
variable "queue_worker_prod_nodes_instance_types" {
   type        = list(string)
  description = "List of EC2 instance types for the node group"
}

variable "prod_disk_size" {
  type = number
}

variable "prod_taints" {
  default = []
}

variable "queue_worker_prod_taints" {
  type =list(any)
}

variable "prod_special_node_group_name" {
  type = string
}


variable "prod_special_nodes_instance_types" {
  default = ["t3.medium"]
}

variable "prod_special_disk_size" {
  type = number
}

variable "prod_special_taints" {
  default = []
}



variable "scaling_config" {
}

variable "special_scaling_config" {
}

variable "monitoring_scaling_config" {
}

variable "prod_scaling_config" {
}

variable "queue_worker_prod_scaling_config" {
  type = any
  description = "Scaling configuration mapping for the node group"
}

variable "prod_special_scaling_config" {
}


variable "storage_type" {

}
variable "iops" {

}
variable "max_allocated_storage" {

}
variable "monitoring_interval" {

}
variable "parameter_group_name" {

}
variable "instance_class" {

}
variable "allocated_storage" {
  type = number
  default = 20

}

variable "prod_storage_type" {

}
variable "prod_iops" {

}
variable "prod_allocated_storage" {

}
variable "prod_max_allocated_storage" {

}

variable "prod_instance_class" {

}
variable "prod_rds_identifier" {

}

variable "mysql_rds_secret_name" {

}
variable "mysql_rds_username" {

}





variable "docdb_cluster_identifier" {
  description = "Cluster identifier for DocumentDB"
  type        = string
  default     = "my-docdb-cluster"
}

variable "docdb_instance_class" {
  description = "Instance class for DocumentDB"
  type        = string
  default     = "db.t3.medium"
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
  default     = 5
}


variable "preferred_backup_window" {
  description = "Backup window"
  type        = string
  default     = "07:00-09:00"
}

variable "docdb_secret_name" {
  description = "Secret name for Secrets Manager"
  type        = string
  default     = "docdb-credentials"
}

variable "docdb_username" {
  description = "Master username for DocumentDB"
  type        = string
  default     = "my_project-docdb-user"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Name        = "docdb-cluster"
    env         = "Staging"
    Project     = "my_project"
    Provisioner = "Terraform"
    Owner       = "CloudHero"
  }
}
variable "availability_zones" {
  description = "Availablity zones"
  type        = list(string)
  default   = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}
variable "cidr_blocks" {
  description = "Allowed CIDR blocks"
  type        = list(string)
}



variable "prod_docdb_cluster_identifier" {
  description = "Cluster identifier for DocumentDB"
  type        = string
  default     = "prod-docdb-cluster"
}

variable "prod_docdb_instance_class" {
  description = "Instance class for DocumentDB"
  type        = string
  default     = "db.t3.medium"
}

variable "prod_backup_retention_period" {
  description = "Backup retention period"
  type        = number
  default     = 5
}


variable "prod_preferred_backup_window" {
  description = "Backup window"
  type        = string
  default     = "07:00-09:00"
}

variable "prod_docdb_secret_name" {
  description = "Secret name for Secrets Manager"
  type        = string
  default     = "docdb-credentials"
}

variable "prod_docdb_username" {
  description = "Master username for DocumentDB"
  type        = string
  default     = "my_project-docdb-user"
}

variable "prod-tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Name        = "docdb-cluster"
    env         = "Prod"
    Project     = "my_project"
    Provisioner = "Terraform"
    Owner       = "CloudHero"
  }
}



variable "num_cache_nodes" {
  default = 1
}
variable "prod_num_cache_nodes" {
  default = 1
}
variable "auth_token" {
  type = string
  description = "Authentication token for ElastiCache Redis"
  default = ""

}
variable "prod_auth_token" {

}

variable "identifier" {}
variable "node_type" {}

variable "prod_identifier" {}
variable "prod_node_type" {}

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

variable "private_key_path" {
    default = "./keys/my_project_eks_private.pem"
}

# variable "ingress_rules" {
#   description = "Map of ingress rules with port and cidr_blocks"
#   type = map(object({
#     port         = number
#     cidr_blocks  = list(string)
#   }))
# }


# variable "mongo_ebs_volume_size" {
#   type = number
# }
# variable "mongo_storage_type" {
# }
# variable "mongo_root_volume_size" {
#   type = number
# }
# variable "mongo_root_storage_type" {
# }


# variable "prod_mongo_ebs_volume_size" {
#   type = number
# }
# variable "prod_mongo_storage_type" {
# }
# variable "prod_mongo_root_volume_size" {
#   type = number
# }
# variable "prod_mongo_root_storage_type" {
# }


##### Bottlerocket gp3 Launch Template #####

variable "prod_launch_template_name" {
  description = "Name of the launch template"
  type        = string
}

variable "prod_lt_instance_type" {
  description = "EC2 instance type for node group"
  type        = string
}

variable "prod_lt_root_volume_size" {
  description = "Root volume size (GiB)"
  type        = number
}

variable "prod_lt_root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "prod_lt_data_volume_size" {
  description = "Data volume size (GiB)"
  type        = number
}

variable "prod_lt_data_volume_type" {
  description = "Data volume type"
  type        = string
  default     = "gp3"
}

variable "prod_lt_data_volume_iops" {
  description = "Data volume IOPS"
  type        = number
}

variable "prod_lt_data_volume_throughput" {
  description = "Data volume throughput (MB/s)"
  type        = number
}



variable "staging_launch_template_name" {
  description = "Name of the launch template"
  type        = string
}

variable "staging_lt_instance_type" {
  description = "EC2 instance type for node group"
  type        = string
}

variable "staging_lt_root_volume_size" {
  description = "Root volume size (GiB)"
  type        = number
}

variable "staging_lt_root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "staging_lt_data_volume_size" {
  description = "Data volume size (GiB)"
  type        = number
}

variable "staging_lt_data_volume_type" {
  description = "Data volume type"
  type        = string
  default     = "gp3"
}

variable "staging_lt_data_volume_iops" {
  description = "Data volume IOPS"
  type        = number
}

variable "staging_lt_data_volume_throughput" {
  description = "Data volume throughput (MB/s)"
  type        = number
}


variable "enable_admin_container" {
  description = "Enable Bottlerocket admin container"
  type        = bool
  default     = false
}

variable "enable_control_container" {
  description = "Enable Bottlerocket control container"
  type        = bool
  default     = true
}



### Dynamic Prod setup ### 

variable "node_groups" {
  description = "EKS node groups with launch template configuration"
  type = map(object({
    node_group_name = string

    scaling_config = object({
      min     = number
      max     = number
      desired = number
    })

    labels = map(string)

    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))

    launch_template = object({
      name                   = string
      instance_type          = string
      root_volume_size       = number
      root_volume_type       = string
      data_volume_size       = number
      data_volume_type       = string
      data_volume_iops       = number
      data_volume_throughput = number
      version                = string
    })
  }))
}


### Dynamic Staging setup ### 
# variable "staging_node_groups" {
#   type = map(object({
#     node_group_name = string
#     capacity_type   = string # SPOT | ON_DEMAND

#     scaling_config = object({
#       min     = number
#       max     = number
#       desired = number
#     })

#     labels = map(string)

#     taints = list(object({
#       key    = string
#       value  = string
#       effect = string
#     }))

#     launch_template = object({
#       name                   = string
#       instance_types         = list(string)
#       root_volume_size       = number
#       root_volume_type       = string
#       data_volume_size       = number
#       data_volume_type       = string
#       data_volume_iops       = number
#       data_volume_throughput = number
#       version                = string
#     })
#   }))
# }

# variable "elasticsearch_ingress_rules" {
#   description = "Map of ingress rules with port and cidr_blocks"
#   type = map(object({
#     port         = number
#     cidr_blocks  = list(string)
#   }))
# }


# variable "elasticsearch_root_storage_type" {
  
# }
# variable "elasticsearch_root_volume_size" {
  
# }
# variable "elasticsearch_instance_type" {
  
# }
# variable "elasticsearch_storage_type" {
  
# }

# variable "elasticsearch_ebs_volume_size" {
  
# }


resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-elasticsearch-key"
  public_key = var.public_key
}