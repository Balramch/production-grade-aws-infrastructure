resource "aws_security_group" "this" {
  name        = "appserver-rds-sg"
  description = "Allows access to the RDS on port ${var.rds_port}"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks     = var.db_source_ip
    from_port       = var.rds_port
    to_port         = var.rds_port
    protocol        = "TCP"
    description     = "Allows traffic from this security group on port ${var.rds_port}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

output "rds_secgroups" {
  value = [aws_security_group.this.id]
}