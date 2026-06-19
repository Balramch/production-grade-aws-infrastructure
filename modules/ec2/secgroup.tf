resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allows SSH to Bastion from everywhere"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allows SSH from everywhere"
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["138.199.37.99/32","165.22.18.211/32","68.183.214.146/32"]
    description = "Allows MYQL access from VPN krptn, Staging ERP IP & Prod ERP IP"
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allows OpenVPN from everywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

output "bastion_secgroup" {
  value = aws_security_group.bastion.id
}