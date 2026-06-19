# ============================================================================
# ECR Repositories – Dynamic creation with for_each
# ============================================================================

resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                       = "${var.project_name}-${each.value.name}"
  image_tag_mutability       = each.value.image_tag_mutability
  force_delete               = true

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.encryption_type == "KMS" ? each.value.kms_key_id : null
  }

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name      = "${var.project_name}-${each.value.name}"
      Repository = each.value.name
    }
  )
}

# ============================================================================
# ECR Repository Policies (Optional)
# ============================================================================

resource "aws_ecr_repository_policy" "this" {
  for_each = {
    for k, v in var.repositories : k => v if v.enable_repository_policy && v.repository_policy_json != ""
  }

  repository = aws_ecr_repository.this[each.key].name
  policy      = each.value.repository_policy_json
}

# ============================================================================
# ECR Lifecycle Policies – Automatic image retention and cleanup
# ============================================================================

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.enable_lifecycle_policy ? var.repositories : {}

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${each.value.image_retention_days} days of images"
        selection = {
          tagStatus     = "tagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = each.value.image_retention_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last ${var.default_image_retention_count} images by count"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = var.default_image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
