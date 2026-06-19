
resource "aws_kms_key" "irix_rds_enc_key" {
  description             = "KMS key for IRIX RDS Encryption"
  deletion_window_in_days = var.kms_deletion_window_in_days
}
resource "aws_kms_key" "nova_rds_enc_key" {
  description             = "KMS key for IRIX RDS Encryption"
  deletion_window_in_days = var.kms_deletion_window_in_days
}
resource "aws_kms_key" "tina_rds_enc_key" {
  description             = "KMS key for IRIX RDS Encryption"
  deletion_window_in_days = var.kms_deletion_window_in_days
}