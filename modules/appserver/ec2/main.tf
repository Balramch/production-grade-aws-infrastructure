resource "aws_key_pair" "appserver_keypair" {
  key_name   = "${var.project_name}-appserver-key"
  public_key = var.public_key
}

resource "aws_instance" "app-server" {
  for_each                    = var.vm_configs
  ami                         = "ami-09f224bab7225d943" # AMI for Ubuntu 22.04 LTS
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.appserver_keypair.id
  subnet_id                   = var.appserver_subnet
  vpc_security_group_ids      = [aws_security_group.app-server[each.key].id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = each.value.disk_size
    tags = {
      Name = "${each.key}-root"
    }
  }

  tags = {
    Name = "${each.key}"
  }

  user_data = templatefile("${path.module}/scripts/${each.key}.sh",
  {
    hostname  = "${each.key}"
  })
}
