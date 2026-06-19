resource "aws_efs_file_system" "efs" {
  creation_token   = "${var.environment}-${var.project_name}-efs-eks"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "${var.environment}-EFS"
    Provisioner = "Terraform"
    Project = "${var.project_name}"
  }
}


resource "aws_efs_mount_target" "efs-mt" {
  count           = 3
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
  depends_on = [ aws_security_group.efs_sg ]
}


resource "aws_efs_file_system" "prod-efs" {
  creation_token   = "prod-${var.project_name}-efs-eks"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "prod-EFS"
    Provisioner = "Terraform"
    Project = "${var.project_name}"
  }
}


resource "aws_efs_mount_target" "prod-efs-mt" {
  count           = 3
  file_system_id  = aws_efs_file_system.prod-efs.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
  depends_on = [ aws_security_group.efs_sg ]
}





# EFS SecurityGroups
resource "aws_security_group" "efs_sg" {

  name        = "${var.environment}-efs-sg"
  description = "Allow EFS inbound traffic"
  vpc_id      = var.vpc_id
  dynamic "ingress" {
    for_each = var.efs_sg
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      cidr_blocks = ingress.value
      protocol    = "tcp"
      description = "${ingress.key} port allow NFS Ingress traffic"
    }
  }

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Outbound rule"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
  tags = {
    Name = "${var.environment}-EFS-SG"
    Provisioner = "Terraform"
    Project = "${var.project_name}"

  }
}