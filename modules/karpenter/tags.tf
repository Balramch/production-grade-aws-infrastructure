# Tag subnets for Karpenter discovery
resource "aws_ec2_tag" "subnet_discovery" {
  for_each = toset(var.private_subnets)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tag security groups for Karpenter discovery
resource "aws_ec2_tag" "security_group_discovery" {
  for_each = toset(var.security_group_ids)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}
