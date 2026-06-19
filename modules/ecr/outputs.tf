output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for k, v in aws_ecr_repository.this : k => v.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for k, v in aws_ecr_repository.this : k => v.arn
  }
}

output "registry_id" {
  description = "The AWS account ID (ECR registry ID)"
  value       = data.aws_caller_identity.current.account_id
}

