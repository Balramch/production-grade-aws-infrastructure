resource "aws_security_group" "app-server" {
  for_each    = var.vm_configs
  name        = "${var.project_name}-app-server-${each.key}-sg"
  description = "Security group for ${each.key} server"
  vpc_id      = var.vpc_id

  # Dynamic block for ingress rules
  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-server-${each.key}-sg"
  }
}
