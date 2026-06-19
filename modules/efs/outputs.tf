output "efs_id" {
  description = "EFS name/ID"
  value = aws_efs_file_system.efs.dns_name
}