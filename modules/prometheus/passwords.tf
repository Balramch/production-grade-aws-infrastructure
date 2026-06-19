resource "random_password" "grafana_admin" {
  length      = 16
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_special = 1
  min_numeric = 1
}

resource "random_password" "grafana_db" {
  length      = 16
  special     = false
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}