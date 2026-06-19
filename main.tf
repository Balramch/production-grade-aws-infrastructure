

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  region_azs          = var.region_azs
  num_public_subnets  = var.num_public_subnets
  num_private_subnets = var.num_private_subnets
  project_name        = local.project_name
  create_vpc_flow_log = true
  single_nat_gateway  = false 
  #private_nat_eni_ids     = var.private_nat_eni_ids
  # private_nat_eni_ids = data.aws_network_interfaces.dynamic_nats.ids
  private_subnet_tags = var.private_subnet_tags
  public_subnet_tags = {
    "kubernetes.io/role/elb"           = "1"
    ## I am changing kubernetes.io/role/internal-elb to above because it is public subnet tags.
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  private_subnets   = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id
  eks_api_access    = [module.bastion.bastion_secgroup]
  project_name      = local.project_name
  argo_workflows_sa = "cicd:argo-workflow"
}

module "eks_general_nodes" {
  source                            = "./modules/eks_node_group"
  cluster_name                      = module.eks.cluster_name
  private_subnets                   = module.vpc.private_subnets
  vpc_id                            = module.vpc.vpc_id
  nodegroup_ami_type                = var.nodegroup_ami_type
  disk_size                         = var.disk_size
  project_name                      = local.project_name
  special_node_group_name           = var.special_node_group_name
  special_nodes_instance_types      = var.special_nodes_instance_types
  special_disk_size                 = var.special_disk_size
  special_taints                    = var.special_taints
  monitoring_node_group_name        = var.monitoring_node_group_name
  monitoring_nodes_instance_types   = var.monitoring_nodes_instance_types
  monitoring_disk_size              = var.monitoring_disk_size
  monitoring_taints                 = var.monitoring_taints
  prod_node_group_name              = var.prod_node_group_name
  queue_worker_prod_node_group_name    = var.queue_worker_prod_node_group_name
  prod_nodes_instance_types         = var.prod_nodes_instance_types
  queue_worker_prod_nodes_instance_types  = var.queue_worker_prod_nodes_instance_types
  queue_worker_prod_taints            = var.queue_worker_prod_taints  
  prod_disk_size                    = var.prod_disk_size
  prod_taints                       = var.prod_taints
  prod_special_node_group_name      = var.prod_special_node_group_name
  prod_special_nodes_instance_types = var.prod_special_nodes_instance_types
  prod_special_disk_size            = var.prod_special_disk_size
  prod_special_taints               = var.prod_special_taints
  scaling_config                    = var.scaling_config
  special_scaling_config            = var.prod_special_scaling_config
  monitoring_scaling_config         = var.monitoring_scaling_config
  prod_scaling_config               = var.prod_scaling_config
  queue_worker_prod_scaling_config     = var.queue_worker_prod_scaling_config
  prod_special_scaling_config       = var.prod_special_scaling_config

  cluster_version = var.cluster_version
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_base64 = module.eks.cluster_ca_base64
  aws_region = var.aws_region
  prod_launch_template_name = var.prod_launch_template_name
  prod_lt_instance_type = var.prod_lt_instance_type
  prod_lt_root_volume_size = var.prod_lt_root_volume_size
  prod_lt_root_volume_type = var.prod_lt_root_volume_type

  prod_lt_data_volume_size        = var.prod_lt_data_volume_size
  prod_lt_data_volume_type        = var.prod_lt_data_volume_type
  prod_lt_data_volume_iops        = var.prod_lt_data_volume_iops
  prod_lt_data_volume_throughput  = var.prod_lt_data_volume_throughput
  enable_admin_container   = var.enable_admin_container
  enable_control_container = var.enable_control_container
  node_groups = var.node_groups
} 

module "karpenter" {
  source = "./modules/karpenter"
  
  cluster_name      = module.eks.cluster_name
  cluster_version   = var.cluster_version
  project_name      = local.project_name
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  security_group_ids = [
    module.eks.default_secgroup  # Cluster security group used by nodes
  ]
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  aws_region        = var.aws_region
  ## Karpenter role arn is fetched from the data source in the module itself, so no need to pass it here.
  karpenter_role_arn = data.aws_iam_role.karpenter.arn
  # Optional: Configure node affinity to run Karpenter on existing node groups
  # node_affinity_node_groups = [
  #   var.special_node_group_name,
  #   var.monitoring_node_group_name
  # ]
  
  tags = var.common_tags
}

module "bastion" {
  source                = "./modules/ec2"
  bastion_subnet        = module.vpc.public_subnets[0] # eu-north-1a
  vpc_id                = module.vpc.vpc_id
  public_key            = var.public_key
  helmfile_version      = var.helmfile_version
  kubectl_version       = var.kubectl_version
  eks_cluster_arn       = module.eks.cluster_arn
  bastion_instance_type = var.bastion_instance_type
  project_name          = local.project_name
  efs_dns_name          = module.efs.efs_id
}

module "efs" {
  source          = "./modules/efs"
  environment     = var.environment
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  efs_sg          = var.efs_sg
  private_subnets = module.vpc.private_subnets

}

## ECR 

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  region       = var.aws_region

  # Simple configuration with default settings
  repositories = {
    backend = {
      name                 = "backend"
      enable_image_scan    = true
      scan_on_push         = true
      image_retention_days = 30
    }
    frontend = {
      name                 = "frontend"
      enable_image_scan    = true
      scan_on_push         = true
      image_retention_days = 30
    }
    worker = {
      name                 = "worker"
      enable_image_scan    = true
      scan_on_push         = true
      image_retention_days = 14
    }
  }

  # Lifecycle policy settings
  enable_lifecycle_policy      = true
  default_image_retention_count = 10

  common_tags = merge(
    var.common_tags,
    {
      Module = "ECR"
    }
  )
}


module "rds" {
  source                     = "./modules/rds"
  mysql_subnets              = module.vpc.private_subnets
  vpc_id                     = module.vpc.vpc_id
  identifier                 = var.rds_identifier
  rds_port                   = "3306"
  project_name               = local.project_name
  allocated_storage          = var.allocated_storage
  db_source_ip               = var.db_source_ip
  instance_class             = var.instance_class
  parameter_group_name       = var.parameter_group_name
  storage_type               = var.storage_type
  iops                       = var.iops
  max_allocated_storage      = var.max_allocated_storage
  prod_allocated_storage     = var.prod_allocated_storage
  prod_rds_identifier        = var.prod_rds_identifier
  prod_storage_type          = var.prod_storage_type
  prod_iops                  = var.prod_iops
  prod_max_allocated_storage = var.prod_max_allocated_storage
  prod_instance_class        = var.prod_instance_class
  mysql_rds_secret_name      = var.mysql_rds_secret_name
  mysql_rds_username         = var.mysql_rds_username
  monitoring_interval        = var.monitoring_interval

  engine = "mysql"
}


# module "documentdb" {
#   source                        = "./modules/documentdb"
#   vpc_id                        = module.vpc.vpc_id
#   cidr_blocks                   = var.cidr_blocks
#   subnet_ids                    = module.vpc.private_subnets
#   docdb_cluster_identifier      = var.docdb_cluster_identifier
#   docdb_instance_class          = var.docdb_instance_class
#   backup_retention_period       = var.backup_retention_period
#   preferred_backup_window       = var.preferred_backup_window
#   docdb_secret_name             = var.docdb_secret_name
#   docdb_username                = var.docdb_username
#   tags                          = var.tags
#   availability_zones            = var.availability_zones
#   prod_docdb_cluster_identifier = var.prod_docdb_cluster_identifier
#   prod_docdb_instance_class     = var.prod_docdb_instance_class
#   prod_backup_retention_period  = var.prod_backup_retention_period
#   prod_preferred_backup_window  = var.prod_preferred_backup_window
#   prod_docdb_secret_name        = var.prod_docdb_secret_name
#   prod_docdb_username           = var.prod_docdb_username
#   prod-tags                     = var.prod-tags

# }