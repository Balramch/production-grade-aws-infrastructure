# ECR Module

This module provides a dynamic way to create and manage AWS Elastic Container Registry (ECR) repositories with automated image retention policies, encryption, and scanning configurations.

## Features

- **Dynamic Repository Creation**: Use `for_each` to create multiple repositories from a single module call
- **Image Scanning**: Automatic image vulnerability scanning on push
- **Image Retention Policies**: Automatic cleanup of old images based on age or count
- **Encryption**: Support for both AES256 and KMS encryption
- **Repository Policies**: Optional custom repository access policies
- **Image Tag Mutability**: Control whether image tags can be overwritten
- **Comprehensive Outputs**: Easy access to repository URLs, ARNs, and metadata

## Usage

### Basic Example (Single Repository)

```hcl
module "ecr" {
  source = "./modules/ecr"

  project_name = "my_project"
  region       = var.region
  common_tags  = var.common_tags

  repositories = {
    backend = {
      name                 = "backend"
      enable_image_scan    = true
      scan_on_push         = true
      image_retention_days = 30
      tags = {
        Team = "Platform"
      }
    }
  }
}
```

### Advanced Example (Multiple Repositories)

```hcl
module "ecr" {
  source = "./modules/ecr"

  project_name = "my_project"
  region       = var.region
  common_tags  = var.common_tags

  repositories = {
    backend = {
      name                    = "backend"
      enable_image_scan       = true
      scan_on_push            = true
      image_tag_mutability    = "IMMUTABLE"
      image_retention_days    = 30
      encryption_type         = "KMS"
      kms_key_id              = aws_kms_key.ecr.arn
      enable_repository_policy = false
      tags = {
        Team        = "Platform"
        Environment = "prod"
      }
    }
    frontend = {
      name                 = "frontend"
      enable_image_scan    = true
      scan_on_push         = true
      image_retention_days = 15
      tags = {
        Team        = "Frontend"
        Environment = "prod"
      }
    }
    worker = {
      name                 = "worker"
      enable_image_scan    = true
      image_retention_days = 7
    }
  }

  enable_lifecycle_policy      = true
  default_image_retention_count = 10
}
```

### Accessing Repository Outputs

```hcl
# Get all repository URLs
output "ecr_urls" {
  value = module.ecr.repository_urls
}

# Get a specific repository URL
output "backend_repo_url" {
  value = module.ecr.repository_urls["backend"]
}

# Get registry ID (AWS account ID)
output "registry_id" {
  value = module.ecr.registry_id
}
```

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project_name` | string | - | Project name for resource naming |
| `region` | string | - | AWS region |
| `repositories` | map(object) | {} | Map of repositories to create (see schema below) |
| `common_tags` | map(string) | {} | Common tags for all resources |
| `enable_lifecycle_policy` | bool | true | Enable automatic image retention policies |
| `default_image_retention_count` | number | 10 | Default number of images to keep per repo |
| `registry_scan_config` | object | {} | Organization-wide registry scan configuration |

### Repository Object Schema

Each repository in the `repositories` map accepts:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | required | Repository name (appended after project_name) |
| `enable_image_scan` | bool | true | Enable image scanning |
| `scan_on_push` | bool | true | Scan images automatically on push |
| `encryption_type` | string | "AES256" | "AES256" or "KMS" |
| `kms_key_id` | string | null | KMS key ID for encryption (if type is KMS) |
| `image_tag_mutability` | string | "MUTABLE" | "MUTABLE" or "IMMUTABLE" |
| `image_retention_days` | number | 30 | Days to retain images |
| `enable_repository_policy` | bool | false | Enable custom repository policy |
| `repository_policy_json` | string | "" | JSON policy document |
| `tags` | map(string) | {} | Repository-specific tags |

## Outputs

| Output | Description |
|--------|-------------|
| `repository_urls` | Map of repository keys to their push URLs |
| `repository_arns` | Map of repository keys to their ARNs |
| `registry_id` | AWS account ID (ECR registry ID) |
| `repositories` | Detailed information about all repositories |
| `repository_names` | Map of repository keys to their full names |

## Examples

### Using with EKS Worker Nodes (IAM Policy)

```hcl
resource "aws_iam_role_policy" "eks_ecr_access" {
  name = "${var.project_name}-eks-ecr-access"
  role = aws_iam_role.eks_node_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = module.ecr.repository_arns
      }
    ]
  })
}
```

### Pulling Images in EKS

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example
spec:
  containers:
  - name: backend
    image: ${REGISTRY_ID}.dkr.ecr.${REGION}.amazonaws.com/my_project-backend:latest
    imagePullPolicy: IfNotPresent
```

Get the values:
```bash
REGISTRY_ID=$(terraform output -raw registry_id)
BACKEND_URL=$(terraform output -json repository_urls | jq -r '.backend')
```

## Lifecycle Policies

The module automatically creates lifecycle policies for each repository with two rules:

1. **Age-based**: Expire images older than `image_retention_days`
2. **Count-based**: Keep only the latest `default_image_retention_count` images

Customize these by adjusting the variables or modifying `main.tf`.

## Notes

- All repository names are automatically prefixed with `${project_name}-`
- Repositories are created with `force_delete = true` to allow destruction even if they contain images
- Enable KMS encryption for sensitive workloads; set `encryption_type = "KMS"` and provide `kms_key_id`
- Use `image_tag_mutability = "IMMUTABLE"` for production deployments to prevent image overwrites
