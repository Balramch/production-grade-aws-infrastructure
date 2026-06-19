resource "aws_ssm_parameter" "alb_Controller_role_arn" {
  name        = "/${var.project_name}/${var.cluster_name}_utils/alb_controller_role_arn"
  description = "ALB Controller Role ARN for EKS"
  type        = "SecureString"
  value       = aws_iam_role.alb_controller.arn
}