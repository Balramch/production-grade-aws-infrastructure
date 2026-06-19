resource "aws_kms_key" "etcd" {
  description = "KMS key for secret encryption in ETCD"

  tags = {
    Name = "${var.project_name}-${var.cluster_name}-etcd"
  }
}