variable "cluster_name" {}
variable "private_subnets" {}
variable "vpc_id" {}
variable "project_name" {}

variable "general_nodes_instance_types" {
  default = ["t3.medium"]
}

variable "node_group_name" {
  default = "general-nodes"
}
variable "disk_size" {
  type = string
}
variable "eks_labels" {
  default = {
    role       = "worker-nodes"
    node-group = "general-nodes"
  }
}

variable "special_eks_labels" {
  default = {
    role       = "worker-nodes"
    node-group = "cronjob-special-nodes"
  }
}

variable "monitoring_eks_labels" {
  default = {
    role       = "worker-nodes"
    node-group = "monitoring-nodes"
  }
}


variable "prod_eks_labels" {
  default = {
    role       = "worker-nodes-disabled"
    node-group = "prod-general-nodes-disabled"
  }
}

variable "prod_special_eks_labels" {
  default = {
    role       = "worker-nodes"
    node-group = "special-prod-nodes"
  }
}

variable "queue_worker_prod_eks_labels" {
  default = {
    role       = "queue-worker-nodes"
    node-group = "prod-api-queue-worker"
  }
}

variable "scaling_config" {
  default = {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
}


variable "special_scaling_config" {
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

variable "monitoring_scaling_config" {
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

variable "prod_scaling_config" {
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

variable "queue_worker_prod_scaling_config" {
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

variable "prod_special_scaling_config" {
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}
variable "taints" {
  default = []
}

variable "nodegroup_ami_type" {
  description = "The AMI type to use for the EKS node group, e.g., BOTTLEROCKET_x86_64 or BOTTLEROCKET_ARM_64"
  type        = string
}

variable "special_node_group_name" {
  type = string
}


variable "special_nodes_instance_types" {
  default = ["t3.medium"]
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
  default = ["t3.medium"]
}
variable "prod_disk_size" {
  type = number
}

variable "prod_taints" {
  default = []
}

variable "queue_worker_prod_taints" {
  default = []
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


##### Bottlerocket gp3 Launch Template #####

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_base64" {
  description = "Base64 encoded cluster CA certificate"
  type        = string
}


variable "aws_region" {
  description = "AWS region"
  type        = string
}

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

variable "tags" {
  description = "Extra tags for instances"
  type        = map(string)
  default     = {
    Environment = "prod"
    Project     = "genesys"
    ManagedBy   = "terraform"
  }
}
### Dynamic prod setup ### 

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
