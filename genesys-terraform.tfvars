aws_region            = "eu-north-1"
environment           = "dev"
profile               = "my_project"
region_azs            = ["a", "b", "c"]
project_name          = "my_project"
num_public_subnets    = 3
num_private_subnets   = 3
cluster_name          = "my_project-eks"
cluster_version       = 1.36
vpc_cidr              = "172.40.0.0/16"
helmfile_version      = "v4.2.0"
kubectl_version       = "v1.36.2"
public_key            = "ssh-rsa AAAAB3NzasC1yc2EskaAAAADAQAsksjskjlkjqBAAABgQC1Iu++4RVdYWbLYgzz2R7s2jj7NYSXcoCQ9vne52MVAdf/RVR4A16oGxYBQ7pXTxk29Us3mqTEm2z+ZMMpBXY7r0LXBGArZZ47EiKwU5YxhU0uIarcfP8HlO8XFC6aLKaaSet2Z+ddgxFfwFakhIsFEtQoI5Tr52FH3uBY5dmVzxbi4dsEVhlois1HYk9lE09uKBeYBkRCE4l61sWL2DTxo+dFb0HCgmlW/XrNN5A8EHfE4f+q1PDw4GDgDeIlonmBllwBsM8JQAg65B4puHb4xFm+l1QXTdGo2NrXYrg31LK3BeTpwmGPARfFFIlWna1jOgLO0bnIfEFfRTL3wV/QAaILdbqUXjhaU8FnRaTIlbuX3uRC71hI50/JOpd534yoOFHSUpsoQ21C6Fq0mSmyrq+8A0TM+L7B9YJCZb+UKuQDLg0HiZ6ZZtF3Z3mW5MrrQWnzlanRzUvO4f1+jkfNiKeGa1bfaRLC3jhPcYO5f+ziMsQwSaLCEfYprsx8/a8= my_project-eks@cloudhero.io"
bastion_instance_type = "t3.micro"
nodegroup_ami_type    = "BOTTLEROCKET_x86_64"
disk_size             = "200"
db_source_ip          = ["172.40.0.0/16"]
common_tags = {
  "Project-Name" = "my_project"
  "Managed-By"   = "Terraform"
  "Environment"  = "Dev"
  "Owner"        = "Cloudhero"
}
rds_identifier = "my_project"
private_subnet_tags = {
  "my_project.sh/discovery" = "my_project-eks"
  "kubernetes.io/role/internal-elb"  = "1"
  "kubernetes.io/cluster/my_project-eks" = "shared"
}
efs_sg = {
  "2049" = ["172.40.0.0/16"]
}

## This is static we make it dynamic
## private_nat_eni_ids = ["eni-09b2b613907e2ca90", "eni-0fb0b98dc1c94feee", "eni-0daa1fd3122b62d9c"] # Make sure its in order with AZ a,b,c

special_node_group_name = "gp3-bottlerocket-staging-cronjob-nodegroup"

special_nodes_instance_types = ["t3.large"]

special_disk_size = 100

special_taints = [
  {
    key    = "node-role"
    value  = "cronjob"
    effect = "NO_SCHEDULE"
  },
  {
    key    = "workload"
    value  = "high-compute"
    effect = "PREFER_NO_SCHEDULE"
  }
]


monitoring_node_group_name = "gp3-bottlerocket-monitoring-nodegroup"

monitoring_nodes_instance_types = ["t3.small"]

monitoring_disk_size = 100

monitoring_taints = [
  {
    key    = "node-role"
    value  = "monitoring"
    effect = "NO_SCHEDULE"
  },
  {
    key    = "workload"
    value  = "low-compute"
    effect = "PREFER_NO_SCHEDULE"
  }
]


prod_node_group_name = "gp3-bottlerocket-prod-general-nodegroup"
queue_worker_prod_node_group_name = "gp3-bottlerocket-prod-queue-worker-nodegroup"

prod_nodes_instance_types = ["t3a.xlarge"]
queue_worker_prod_nodes_instance_types = ["t3.small"]

prod_disk_size = 100

prod_taints = [
  {
    key    = "node-role"
    value  = "production-general-disabled"
    effect = "NO_SCHEDULE"
  },
  {
    key    = "workload"
    value  = "small-compute-disabled"
    effect = "PREFER_NO_SCHEDULE"
  }
]

queue_worker_prod_taints = [
  {
    key    = "node-role"
    value  = "prod-api-queue-worker"
    effect = "NO_SCHEDULE"
  },
  {
    key    = "workload"
    value  = "small-compute"
    effect = "PREFER_NO_SCHEDULE"
  }
]

prod_special_node_group_name = "gp3-bottlerocket-prod-special-nodegroup"

prod_special_nodes_instance_types = ["t3a.xlarge"]

prod_special_disk_size = 100

prod_special_taints = [
  {
    key    = "node-role"
    value  = "production-special"
    effect = "NO_SCHEDULE"
  },
  {
    key    = "workload"
    value  = "high-compute"
    effect = "PREFER_NO_SCHEDULE"
  }
]

scaling_config = {
  desired_size = 1
  max_size     = 5
  min_size     = 2
}

special_scaling_config = {
  desired_size = 1
  max_size     = 5
  min_size     = 2
}

monitoring_scaling_config = {
  desired_size = 1
  max_size     = 5
  min_size     = 2
}

prod_scaling_config = {
  desired_size = 1
  max_size     = 5
  min_size     = 2
}

queue_worker_prod_scaling_config = {
  desired_size = 1
  max_size     = 5
  min_size     = 2
}

prod_special_scaling_config = {
  desired_size = 1
  max_size     = 5
  min_size     = 2
}




storage_type          = "gp2"
iops                  = "0"
max_allocated_storage = "1000"
monitoring_interval   = "60"
parameter_group_name  = "my_project-mysql-cnf"
instance_class        = "db.t3.large"
allocated_storage     = "50"

prod_allocated_storage     = "100"
prod_rds_identifier        = "prod-my_project"
prod_storage_type          = "gp2"
prod_iops                  = "12000"
prod_max_allocated_storage = "1000"
prod_instance_class        = "db.m8g.xlarge"

mysql_rds_secret_name = "prod-mysql-rds-secret"
mysql_rds_username    = "admin"


docdb_cluster_identifier = "staging-my_project-docdb-cluster"
docdb_instance_class     = "db.t3.small"
backup_retention_period  = 7
preferred_backup_window  = "07:00-09:00"
docdb_secret_name        = "staging-docdb-credentails"
docdb_username           = "stagingmy_projectUser"
tags = {
  Name        = "docdb-cluster"
  env         = "Staging"
  Project     = "my_project"
  Provisioner = "Terraform"
  Owner       = "CloudHero"
}

prod_docdb_cluster_identifier = "prod-my_project-docdb-cluster"
prod_docdb_instance_class     = "db.r6g.xlarge"
prod_backup_retention_period  = 7
prod_preferred_backup_window  = "07:00-09:00"
prod_docdb_secret_name        = "prod-docdb-credentails"
prod_docdb_username           = "Prodmy_projectUser"
prod-tags = {
  Name        = "docdb-cluster"
  env         = "Prod"
  Project     = "my_project"
  Provisioner = "Terraform"
  Owner       = "CloudHero"
}


availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
cidr_blocks        = ["172.40.0.0/16"]

num_cache_nodes      = 1
prod_num_cache_nodes = 1
auth_token           = "gGR6duniwiwiwKyvAVKsuCuykskVPvUy5KLEflDnC"
prod_auth_token      = "A07YddBVqlV5ZLprHpakjs9G3AcbF9Dl9VexQ"
identifier           = "my_project"
node_type            = "cache.t3.small"
prod_identifier      = "my_project-prod"
prod_node_type       = "cache.r7g.large"



#### APP SERVER

# VM configs

vm_configs = {
    irix = {
      instance_type = "t3.small"      
      disk_size = 1200
      ingress_rules = [
        { port = 22, cidr_blocks = ["18.196.20.209/32","86.126.134.61/32","5.2.137.66/32","3.67.22.80/32","128.127.112.194/32"] },
        { port = 80, cidr_blocks = ["0.0.0.0/0"] },
        { port = 9100, cidr_blocks = ["172.40.0.0/16"] },
        { port = 443, cidr_blocks = ["0.0.0.0/0"] }
      ]

    }
    nova = {
      instance_type = "t3.small"
      disk_size = 500
      ingress_rules = [
        { port = 22, cidr_blocks = ["18.196.20.209/32","86.126.134.61/32","5.2.137.66/32","3.67.22.80/32","128.127.112.194/32"] },
        { port = 8080, cidr_blocks = ["172.40.0.0/16"] },
        { port = 9100, cidr_blocks = ["172.40.0.0/16"] },
        { port = 80, cidr_blocks = ["0.0.0.0/0"] },
        { port = 443, cidr_blocks = ["0.0.0.0/0"] }
      ]
    }
    tina = {
      instance_type = "t3a.small"
      disk_size = 100
      ingress_rules = [
        { port = 22, cidr_blocks = ["172.40.0.0/16","18.196.20.209/32","86.126.134.61/32","5.2.137.66/32","3.67.22.80/32","128.127.112.194/32","128.127.122.218/32","194.156.171.22/32","82.150.225.129/32"] },
        { port = 5432, cidr_blocks = ["172.40.0.0/16"] },
        { port = 9100, cidr_blocks = ["172.40.0.0/16"] },
        { port = 80, cidr_blocks = ["0.0.0.0/0"] },
        { port = 443, cidr_blocks = ["0.0.0.0/0"] }
      ]
    }
  }

##### Bottlerocket gp3 Launch Template #####


##### Launch Template #####

prod_launch_template_name = "prod-bottlerocket-gp3-lt"

prod_lt_instance_type = "t3a.xlarge"

# Root volume (OS)
prod_lt_root_volume_size = 5
prod_lt_root_volume_type = "gp3"

# Data / container volume
prod_lt_data_volume_size        = 100
prod_lt_data_volume_type        = "gp3"
prod_lt_data_volume_iops        = 3000
prod_lt_data_volume_throughput  = 125

staging_launch_template_name = "staging-bottlerocket-gp3-lt"

staging_lt_instance_type = "t3.small"

# Root volume (OS)
staging_lt_root_volume_size = 5
staging_lt_root_volume_type = "gp3"

# Data / container volume
staging_lt_data_volume_size        = 100
staging_lt_data_volume_type        = "gp3"
staging_lt_data_volume_iops        = 3000
staging_lt_data_volume_throughput  = 125


##### Bottlerocket options #####

enable_admin_container   = false
enable_control_container = true





### Dynamic Prod LT & Nodegroups ###


node_groups = {
  optimized-prod-general-nodegroup= {
    node_group_name = "optimized-bottlerocket-prod-general-nodegroup"

    scaling_config = {
      min     = 1
      max     = 5
      desired = 2
    }

    labels = {
      role       = "worker-nodes"
      node-group = "prod-general-nodes"
    }

    taints = [
        {
          key    = "node-role"
          value  = "production-general"
          effect = "NO_SCHEDULE"
        },
        {
          key    = "workload"
          value  = "small-compute"
          effect = "PREFER_NO_SCHEDULE"
        }
    ]

    launch_template = {
      name                   = "optimized-prod-general-bottlerocket-gp3-lt"
      instance_type          = "c7a.xlarge"
      root_volume_size       = 10
      root_volume_type       = "gp3"
      data_volume_size       = 100
      data_volume_type       = "gp3"
      data_volume_iops       = 3000
      data_volume_throughput = 125
      version                = "2"
      # version                = "$Latest"
    }
  }




}

