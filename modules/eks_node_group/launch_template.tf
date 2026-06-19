locals {
  eks_version = var.cluster_version
}

data "aws_ssm_parameter" "bottlerocket_image_id" {
  name = "/aws/service/bottlerocket/aws-k8s-${local.eks_version}/x86_64/latest/image_id"
}

data "aws_ami" "bottlerocket_image" {
  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.bottlerocket_image_id.value]
  }
}


# resource "aws_launch_template" "prod-bottlerocket-launch-template" {

#   name                   = var.prod_launch_template_name
#   image_id               = data.aws_ami.bottlerocket_image.id
#   instance_type          = var.prod_lt_instance_type
#   update_default_version = true

#   # Data volume (container storage)
#   block_device_mappings {
#     device_name = "/dev/xvdb"
#     ebs {
#       volume_size           = var.prod_lt_data_volume_size
#       volume_type           = var.prod_lt_data_volume_type
#       iops                  = var.prod_lt_data_volume_iops
#       throughput            = var.prod_lt_data_volume_throughput
#       delete_on_termination = true
#     }
#   }

#   # Root volume (OS)
#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       delete_on_termination = true
#       volume_size = var.prod_lt_root_volume_size
#       volume_type = var.prod_lt_root_volume_type
#     }
#   }

#   # Tags for autoscaler + cluster
#   tag_specifications {
#     resource_type = "instance"
#     tags = merge(
#       {
#         Name                                                        = var.prod_launch_template_name
#         "kubernetes.io/cluster/${var.cluster_name}"               = "owned"
#         "k8s.io/cluster-autoscaler/${var.cluster_name}"           = "owned"
#         "k8s.io/cluster-autoscaler/enabled"                       = "true"
#       },
#       var.tags
#     )
#   }

#   network_interfaces {
#     associate_public_ip_address = false
#   }

#   metadata_options {
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 2
#   }

#   user_data = base64encode(templatefile("${path.module}/config.toml",
#     {
#       cluster_name             = var.cluster_name
#       endpoint                 = var.cluster_endpoint
#       cluster_auth_base64      = var.cluster_ca_base64
#       aws_region               = var.aws_region
#       enable_admin_container   = var.enable_admin_container
#       enable_control_container = var.enable_control_container
#     }
#   ))
# }


# resource "aws_launch_template" "staging-bottlerocket-launch-template" {

#   name                   = var.staging_launch_template_name
#   image_id               = data.aws_ami.bottlerocket_image.id
#   instance_type          = var.staging_lt_instance_type
#   update_default_version = true

#   # Data volume (container storage)
#   block_device_mappings {
#     device_name = "/dev/xvdb"
#     ebs {
#       volume_size           = var.staging_lt_data_volume_size
#       volume_type           = var.staging_lt_data_volume_type
#       iops                  = var.staging_lt_data_volume_iops
#       throughput            = var.staging_lt_data_volume_throughput
#       delete_on_termination = true
#     }
#   }

#   # Root volume (OS)
#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       delete_on_termination = true
#       volume_size = var.staging_lt_root_volume_size
#       volume_type = var.staging_lt_root_volume_type
#     }
#   }

#   # Tags for autoscaler + cluster
#   tag_specifications {
#     resource_type = "instance"
#     tags = merge(
#       {
#         Name                                                        = var.staging_launch_template_name
#         "kubernetes.io/cluster/${var.cluster_name}"               = "owned"
#         "k8s.io/cluster-autoscaler/${var.cluster_name}"           = "owned"
#         "k8s.io/cluster-autoscaler/enabled"                       = "true"
#       },
#       var.tags
#     )
#   }

#   network_interfaces {
#     associate_public_ip_address = false
#   }

#   metadata_options {
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 2
#   }

#   user_data = base64encode(templatefile("${path.module}/config.toml",
#     {
#       cluster_name             = var.cluster_name
#       endpoint                 = var.cluster_endpoint
#       cluster_auth_base64      = var.cluster_ca_base64
#       aws_region               = var.aws_region
#       enable_admin_container   = var.enable_admin_container
#       enable_control_container = var.enable_control_container
#     }
#   ))
# }


### Dynamic Prod LT ###
resource "aws_launch_template" "prod-launch-templates" {
  for_each = var.node_groups

  name                   = each.value.launch_template.name
  image_id               = data.aws_ami.bottlerocket_image.id
  # image_id               = "ami-004092e486932f6f7"
  instance_type          = each.value.launch_template.instance_type
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvdb"
    ebs {
      volume_size           = each.value.launch_template.data_volume_size
      volume_type           = each.value.launch_template.data_volume_type
      iops                  = each.value.launch_template.data_volume_iops
      throughput            = each.value.launch_template.data_volume_throughput
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value.launch_template.root_volume_size
      volume_type           = each.value.launch_template.root_volume_type
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                                            = each.value.launch_template.name
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"             = "true"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  user_data = base64encode(templatefile("${path.module}/config.toml", {
    cluster_name             = var.cluster_name
    endpoint                 = var.cluster_endpoint
    cluster_auth_base64      = var.cluster_ca_base64
    aws_region               = var.aws_region
    enable_admin_container   = var.enable_admin_container
    enable_control_container = var.enable_control_container
  }))
}

