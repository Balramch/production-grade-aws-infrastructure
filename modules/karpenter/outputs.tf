output "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_role_name" {
  description = "Name of the Karpenter node IAM role"
  value       = aws_iam_role.karpenter_node.name
}

output "karpenter_controller_role_arn" {
  description = "ARN of the Karpenter controller IAM role"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_controller_role_name" {
  description = "Name of the Karpenter controller IAM role"
  value       = aws_iam_role.karpenter_controller.name
}

output "interruption_queue_name" {
  description = "Name of the SQS queue for spot interruptions"
  value       = var.enable_interruption_queue ? aws_sqs_queue.karpenter_interruption[0].name : null
}

output "interruption_queue_url" {
  description = "URL of the SQS queue for spot interruptions"
  value       = var.enable_interruption_queue ? aws_sqs_queue.karpenter_interruption[0].url : null
}
