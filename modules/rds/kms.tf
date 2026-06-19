resource "aws_kms_key" "rds_enc_key" {
  description             = "KMS key for RDS Encryption"
  deletion_window_in_days = var.kms_deletion_window_in_days
}

resource "aws_kms_key" "prod_rds_enc_key" {
  description             = "KMS key for Prod RDS Encryption"
  deletion_window_in_days = var.kms_deletion_window_in_days
}