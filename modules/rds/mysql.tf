# Generate a random password
resource "random_password" "mysql_rds_random" {
  length           = 16
  special          = true
  override_special = "!%&_"
}

# Create Secrets Manager secret
resource "aws_secretsmanager_secret" "mysql_rds_secretmanager" {
  name = var.mysql_rds_secret_name
}

# Store username + generated password in Secrets Manager
resource "aws_secretsmanager_secret_version" "mysql_rds_secretversion" {
  secret_id = aws_secretsmanager_secret.mysql_rds_secretmanager.id

  secret_string = jsonencode({
    username = var.mysql_rds_username
    password = random_password.mysql_rds_random.result
  })
}

resource "aws_db_instance" "this" {
  allocated_storage            = var.allocated_storage
  engine                       = var.engine
  engine_version               = var.engine_version
  replicate_source_db          = var.replicate_source_db
  instance_class               = var.instance_class
  identifier                   = var.identifier
  username                     = "admin"
  password                     = "5Fpnl2pGSBtgCXx"
  backup_retention_period      = var.backup_retention_period
  deletion_protection          = var.deletion_protection
  parameter_group_name         = var.parameter_group_name
  backup_window                = var.backup_window
  vpc_security_group_ids       = [aws_security_group.this.id]
  db_subnet_group_name         = aws_db_subnet_group.private_group.name
  performance_insights_enabled = var.performance_insights_enabled
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = true
  kms_key_id                   = aws_kms_key.rds_enc_key.arn
  storage_encrypted            = true
  copy_tags_to_snapshot        = true
  multi_az                     = var.multi_az
  skip_final_snapshot          = true
  enabled_cloudwatch_logs_exports       = ["error","slowquery"]
  storage_type         = var.storage_type
  iops                 = var.iops
  max_allocated_storage = var.max_allocated_storage
  monitoring_interval   = var.monitoring_interval
}


resource "aws_db_instance" "prod_mysql_rds" {
  allocated_storage            = var.prod_allocated_storage
  engine                       = var.engine
  engine_version               = var.engine_version
  replicate_source_db          = var.replicate_source_db
  instance_class               = var.prod_instance_class
  identifier                   = var.prod_rds_identifier
  username                     = "admin"
  password                     = random_password.mysql_rds_random.result
  backup_retention_period      = var.prod_backup_retention_period
  deletion_protection          = var.prod_deletion_protection
  parameter_group_name         = var.parameter_group_name
  backup_window                = var.prod_backup_window
  vpc_security_group_ids       = [aws_security_group.this.id]
  db_subnet_group_name         = aws_db_subnet_group.private_group.name
  performance_insights_enabled = var.prod_performance_insights_enabled
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = true
  kms_key_id                   = aws_kms_key.prod_rds_enc_key.arn
  storage_encrypted            = true
  copy_tags_to_snapshot        = true
  multi_az                     = var.multi_az
  skip_final_snapshot          = true
  enabled_cloudwatch_logs_exports       = ["error","slowquery"]
  storage_type         = var.prod_storage_type
  iops                 = var.prod_iops
  max_allocated_storage = var.prod_max_allocated_storage
  # monitoring_interval   = var.monitoring_interval
  monitoring_interval   = "60"
  depends_on = [ random_password.mysql_rds_random ]
  lifecycle {
    ignore_changes = [storage_type]
  }
}