resource "aws_db_subnet_group" "private_group" {
  name       = "${var.identifier}-private-subnet-group"
  subnet_ids = var.mysql_subnets
}