resource "aws_ssm_parameter" "this" {
  name        = "/${var.project_name}/rds_${var.identifier}/admin_password"
  description = "Admin password for ${var.identifier} RDS instance"
  type        = "SecureString"
  value       = random_password.this.result
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}