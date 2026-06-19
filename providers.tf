terraform {
  required_version = "~> 1.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50"
    }
  }
}

# Providers

provider "aws" {
  profile = var.profile
  region  = var.aws_region
  default_tags {
    tags = var.common_tags
  }
}