resource "aws_ssm_parameter" "aps_url" {
  name        = "/${var.project_name}/${var.alias}/endpoint"
  description = "Prometheus Endpoint for EKS monitoring"
  type        = "SecureString"
  value       = "${aws_prometheus_workspace.this.prometheus_endpoint}api/v1/remote_write"
}

resource "aws_ssm_parameter" "aps_role_arn" {
  name        = "/${var.project_name}/${var.alias}/role_arn"
  description = "APS Role ARN for EKS monitoring"
  type        = "SecureString"
  value       = aws_iam_role.this.arn
}

resource "aws_ssm_parameter" "grafana_password" {
  name        = "/${var.project_name}/${var.alias}/grafana_password"
  description = "Grafana Admin password for EKS monitoring"
  type        = "SecureString"
  value       = random_password.grafana_admin.result
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

# This is used for the Grafana and MariaDB Helm Charts.
resource "aws_ssm_parameter" "grafana_db_password" {
  name        = "/${var.project_name}/${var.alias}/grafana_db_password"
  description = "Grafana DB password for EKS monitoring"
  type        = "SecureString"
  value       = random_password.grafana_db.result
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}