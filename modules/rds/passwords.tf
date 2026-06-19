resource "random_password" "this" {
  length      = 16
  special     = false
  min_lower   = 1
  min_upper   = 1
  min_special = 1
  min_numeric = 1
}

output "rds_password" {
  value     = random_password.this.result
  sensitive = false
}