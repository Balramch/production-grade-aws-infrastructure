data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_ssm_parameter" "karpenter_ami" {
  name = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

data "aws_ec2_instance_type_offerings" "available" {
  filter {
    name   = "location"
    values = [var.aws_region]
  }
}

# Get AMI details for alias version extraction
# Note: AMI alias version will be extracted in the EC2NodeClass resource
# For now, we'll use a default value that can be overridden
locals {
  # Default AMI alias version - this can be overridden via variable if needed
  # The actual version will be determined at runtime by Karpenter
  ami_alias_version = "v1" # Default fallback, Karpenter will resolve the actual version
}
