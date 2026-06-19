# ----------------------
# Public route table (single)
# ----------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-rt-public"
    Subnet_Type = "public"
  }
}

# ----------------------
# Private route tables
# Count matches number of NAT gateways:
#   - 1 if single_nat_gateway (shared), else one per private subnet
# ----------------------
resource "aws_route_table" "private_route_table" {
  count = local.nat_gateway_count

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = var.single_nat_gateway ? "${var.project_name}-rt-private" : "${var.project_name}-rt-private-${var.region_azs[count.index]}"
    Subnet_Type = "private"
  }
}

# ----------------------
# Public subnet associations
# All public subnets use the single public route table
# ----------------------
resource "aws_route_table_association" "public_rt_assoc" {
  count = var.num_public_subnets

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id   # all use the same public RT
}

# ----------------------
# Private subnet associations
# If single_nat_gateway, all private subnets use the first (and only) private RT
# Otherwise, each private subnet gets its own RT (one‑to‑one)
# ----------------------
resource "aws_route_table_association" "private_rt_assoc" {
  count = var.num_private_subnets

  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private_route_table[0].id : aws_route_table.private_route_table[count.index].id
}

# ----------------------
# Public egress route (Internet Gateway)
# ----------------------
resource "aws_route" "prod_rt_public_egress" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public_igw.id
}

# ----------------------
# Private egress routes (NAT Gateways)
# One route per private route table, matched to the corresponding NAT gateway
# ----------------------
resource "aws_route" "prod_rt_private_egress" {
  count = local.nat_gateway_count

  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_nat_gws[count.index].id

  # Optional: ignore changes if you manage NAT gateway IDs elsewhere
  # lifecycle {
  #   ignore_changes = [nat_gateway_id]
  # }
}