# ============================================================================
# Example: How to integrate ECR module in your main.tf
# ============================================================================
# Add this to your main.tf file under infra/terraform/aws/

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

# ============================================================================
# Optional: Output the ECR URLs for use in deployment scripts
# ============================================================================

output "ecr_repository_urls" {
  description = "ECR repository URLs for image pushing"
  value       = module.ecr.repository_urls
}

output "ecr_registry_id" {
  description = "ECR registry ID (AWS account ID)"
  value       = module.ecr.registry_id
}

output "ecr_repositories" {
  description = "Complete ECR repository details"
  value       = module.ecr.repositories
}

# ============================================================================
# Optional: Add IAM permissions for EKS nodes to pull images
# ============================================================================
# (Add this to your EKS node role attachment)

resource "aws_iam_role_policy" "eks_ecr_pull" {
  name = "${var.project_name}-eks-ecr-pull"
  role = module.eks.node_role_id  # Adjust based on your EKS module output

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages"
        ]
        Resource = values(module.ecr.repository_arns)
      }
    ]
  })
}
