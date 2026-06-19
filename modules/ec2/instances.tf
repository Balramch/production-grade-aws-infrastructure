# ------------------------------------------------------------------------------
# DATA SOURCE: Fetch the latest Debian 12 AMI for the current region
# ------------------------------------------------------------------------------
data "aws_ami" "debian_12" {
  most_recent = true
  owners      = ["16071363"]  # Official Debian owner ID

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# KEY PAIR – created from your public key
# ------------------------------------------------------------------------------
resource "aws_key_pair" "bastion_keypair" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = var.public_key
}

# ------------------------------------------------------------------------------
# IAM INSTANCE PROFILE – for the bastion to assume the IAM role
# ------------------------------------------------------------------------------
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.project_name}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

# ------------------------------------------------------------------------------
# BASTION EC2 INSTANCE
# ------------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.debian_12.id   # dynamically resolved
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.bastion_keypair.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = var.bastion_subnet
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.id
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
  }

  connection {
    type        = "ssh"
    user        = "admin"                # Debian 12 default user
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "scripts/script.sh"
    destination = "/tmp/script.sh"
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/script.sh",
  #     "/tmp/script.sh ${var.efs_dns_name}",
  #     "set -x",          # Enable verbose logging
  #     "exec 2>&1",       # Redirect stderr to stdout
  #     # ... your existing commands
  #     "echo 'Debug: Script started'",
  #     "aws eks update-kubeconfig --name genesys-eks --region your-region",
  #     "kubectl get nodes --request-timeout=10s", # Fail fast 
  #   ]
   
  # }

  lifecycle {
    ignore_changes = [
      security_groups,   # if you modify security groups outside Terraform
    ]
  }

  tags = {
    Name = "${var.project_name}-bastion"
  }
}