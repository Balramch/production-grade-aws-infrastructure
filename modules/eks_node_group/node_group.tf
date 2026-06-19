### Dynamic Production Nodegroups ### 
resource "aws_eks_node_group" "prod-node-groups" {
  # ... all the above ...
  depends_on = [
    aws_launch_template.prod-launch-templates
  ]
  for_each = var.node_groups

  cluster_name    = var.cluster_name
  node_group_name = each.value.node_group_name
  node_role_arn   = aws_iam_role.this.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    min_size     = each.value.scaling_config.min
    max_size     = each.value.scaling_config.max
    desired_size = each.value.scaling_config.desired
  }

  labels = each.value.labels

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  launch_template {
    id      = aws_launch_template.prod-launch-templates[each.key].id
    # Always use the latest version of the launch template
    version = aws_launch_template.prod-launch-templates[each.key].latest_version
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = each.value.node_group_name
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = true
  }
}
