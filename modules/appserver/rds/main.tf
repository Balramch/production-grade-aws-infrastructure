# Generate a random password
resource "random_password" "mysql_rds_random" {
  length           = 16
  special          = true
  override_special = "!%&_"
}

# Create Secrets Manager secret
resource "aws_secretsmanager_secret" "irix_mysql_rds_secretmanager" {
  name = var.irix_mysql_rds_secret_name
}

# Store username + generated password in Secrets Manager
resource "aws_secretsmanager_secret_version" "irix_mysql_rds_secretversion" {
  secret_id = aws_secretsmanager_secret.irix_mysql_rds_secretmanager.id

  secret_string = jsonencode({
    username = var.mysql_rds_username
    password = random_password.mysql_rds_random.result
  })
}

resource "aws_secretsmanager_secret" "nova_mysql_rds_secretmanager" {
  name = var.nova_mysql_rds_secret_name
}

# Store username + generated password in Secrets Manager
resource "aws_secretsmanager_secret_version" "nova_mysql_rds_secretversion" {
  secret_id = aws_secretsmanager_secret.nova_mysql_rds_secretmanager.id

  secret_string = jsonencode({
    username = var.mysql_rds_username
    password = random_password.mysql_rds_random.result
  })
}

resource "aws_secretsmanager_secret" "tina_mysql_rds_secretmanager" {
  name = var.tina_mysql_rds_secret_name
}

# Store username + generated password in Secrets Manager
resource "aws_secretsmanager_secret_version" "tina_mysql_rds_secretversion" {
  secret_id = aws_secretsmanager_secret.tina_mysql_rds_secretmanager.id

  secret_string = jsonencode({
    username = var.mysql_rds_username
    password = random_password.mysql_rds_random.result
  })
}

resource "aws_db_subnet_group" "private_group" {
  name       = "appserver-private-subnet-group"
  subnet_ids = var.mysql_subnets
}



resource "aws_db_instance" "irix_mysql_rds" {
  allocated_storage            = var.irix_allocated_storage
  engine                       = var.engine
  engine_version               = var.engine_version
  replicate_source_db          = var.replicate_source_db
  instance_class               = var.irix_instance_class
  identifier                   = var.irix_rds_identifier
  username                     = "admin"
  password                     = random_password.mysql_rds_random.result
  backup_retention_period      = var.irix_backup_retention_period
  deletion_protection          = var.irix_deletion_protection
  parameter_group_name         = "irix-karpaten-pg"
  backup_window                = var.irix_backup_window
  vpc_security_group_ids       = [aws_security_group.this.id]
  db_subnet_group_name         = aws_db_subnet_group.private_group.name
  performance_insights_enabled = var.irix_performance_insights_enabled
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = true
  kms_key_id                   = aws_kms_key.irix_rds_enc_key.arn
  storage_encrypted            = true
  copy_tags_to_snapshot        = true
  multi_az                     = var.multi_az
  skip_final_snapshot          = true
  enabled_cloudwatch_logs_exports       = ["error","slowquery"]
  storage_type         = var.irix_storage_type
  # iops                 = var.irix_iops
  max_allocated_storage = var.irix_max_allocated_storage
  # monitoring_interval   = var.monitoring_interval
  monitoring_interval   = "0"
  depends_on = [ random_password.mysql_rds_random ]
  lifecycle {
    ignore_changes = [storage_type]
  }
}

resource "aws_db_instance" "nova_mysql_rds" {
  allocated_storage            = var.nova_allocated_storage
  engine                       = var.engine
  engine_version               = "8.4.3"
  replicate_source_db          = var.replicate_source_db
  instance_class               = var.nova_instance_class
  identifier                   = var.nova_rds_identifier
  username                     = "admin"
  password                     = random_password.mysql_rds_random.result
  backup_retention_period      = var.nova_backup_retention_period
  deletion_protection          = var.nova_deletion_protection
  parameter_group_name         = "nova-karpaten-pg"
  backup_window                = var.nova_backup_window
  vpc_security_group_ids       = [aws_security_group.this.id]
  db_subnet_group_name         = aws_db_subnet_group.private_group.name
  performance_insights_enabled = var.nova_performance_insights_enabled
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = true
  kms_key_id                   = aws_kms_key.nova_rds_enc_key.arn
  storage_encrypted            = true
  copy_tags_to_snapshot        = true
  multi_az                     = var.multi_az
  skip_final_snapshot          = true
  enabled_cloudwatch_logs_exports       = ["error","slowquery"]
  storage_type         = var.nova_storage_type
  # iops                 = var.nova_iops
  max_allocated_storage = var.nova_max_allocated_storage
  # monitoring_interval   = var.monitoring_interval
  monitoring_interval   = "0"
  depends_on = [ random_password.mysql_rds_random ]
  lifecycle {
    ignore_changes = [storage_type]
  }
}


resource "aws_db_instance" "tina_mysql_rds" {
  allocated_storage            = var.tina_allocated_storage
  engine                       = var.engine
  engine_version               = var.engine_version
  replicate_source_db          = var.replicate_source_db
  instance_class               = var.tina_instance_class
  identifier                   = var.tina_rds_identifier
  username                     = "admin"
  password                     = random_password.mysql_rds_random.result
  backup_retention_period      = var.tina_backup_retention_period
  deletion_protection          = var.tina_deletion_protection
  parameter_group_name         = "tina-karpaten-pg"
  backup_window                = var.tina_backup_window
  vpc_security_group_ids       = [aws_security_group.this.id]
  db_subnet_group_name         = aws_db_subnet_group.private_group.name
  performance_insights_enabled = var.tina_performance_insights_enabled
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  apply_immediately            = true
  kms_key_id                   = aws_kms_key.tina_rds_enc_key.arn
  storage_encrypted            = true
  copy_tags_to_snapshot        = true
  multi_az                     = var.multi_az
  skip_final_snapshot          = true
  enabled_cloudwatch_logs_exports       = ["error","slowquery"]
  storage_type         = var.tina_storage_type
  # iops                 = var.tina_iops
  max_allocated_storage = var.tina_max_allocated_storage
  # monitoring_interval   = var.monitoring_interval
  monitoring_interval   = "0"
  depends_on = [ random_password.mysql_rds_random ]
  lifecycle {
    ignore_changes = [storage_type]
  }
}