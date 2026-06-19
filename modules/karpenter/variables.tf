variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for Karpenter nodes"
  type        = list(string)
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https://)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_partition" {
  description = "AWS partition (aws, aws-cn, aws-us-gov)"
  type        = string
  default     = "aws"
}

variable "karpenter_version" {
  description = "Karpenter version to deploy"
  type        = string
  default     = "1.13.0"
}

variable "karpenter_namespace" {
  description = "Kubernetes namespace for Karpenter"
  type        = string
  default     = "kube-system"
}

variable "enable_interruption_queue" {
  description = "Enable SQS queue for spot interruption handling"
  type        = bool
  default     = true
}

variable "node_affinity_node_groups" {
  description = "List of node group names for Karpenter pod node affinity (to run on existing nodes)"
  type        = list(string)
  default     = []
}

variable "nodepool_config" {
  description = "Configuration for the default NodePool"
  type = object({
    instance_architectures = list(string)
    instance_categories    = list(string)
    capacity_types         = list(string)
    min_instance_generation = string
    cpu_limit              = number
    expire_after           = string
    consolidation_policy   = string
    consolidate_after     = string
  })
  default = {
    instance_architectures = ["amd64"]
    instance_categories    = ["c", "m", "r"]
    capacity_types         = ["spot"]
    min_instance_generation = "2"
    cpu_limit              = 1000
    expire_after           = "720h" # 30 days
    consolidation_policy   = "WhenEmptyOrUnderutilized"
    consolidate_after      = "1m"
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}


### Adding new variables for dynamic prod setup ###
variable "karpenter_role_arn" {
  description = "ARN of the IAM role that Karpenter will assume to provision EC2 instances"
  type        = string
}

# If you need to merge with existing roles in aws-auth, you may pass them as a list
variable "current_aws_auth_roles" {
  description = "Existing mapRoles entries to preserve (if any). Typically not needed if you're just adding Karpenter)."
  type        = list(string)
  default     = []
}