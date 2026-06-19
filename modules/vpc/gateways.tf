locals {
  # Number of NAT gateways to create:
  #   - 1 if single_nat_gateway is true
  #   - one per private subnet otherwise
  nat_gateway_count = var.single_nat_gateway ? 1 : var.num_private_subnets

  # Determine which public subnet to use for each NAT gateway
  # If single, use the first public subnet; otherwise use the one with the same index
  nat_subnet_ids = var.single_nat_gateway ? [aws_subnet.public_subnets[0].id] : aws_subnet.public_subnets[*].id
}

resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-public-igw"
  }
}

resource "aws_eip" "nat_gw_ips" {
  count = local.nat_gateway_count

  tags = {
    Name = var.single_nat_gateway ? "${var.project_name}-private-nat-gw-ip" : "${var.project_name}-private-nat-gw-ip-${var.region_azs[count.index]}"
  }
}

resource "aws_nat_gateway" "private_nat_gws" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat_gw_ips[count.index].id
  subnet_id     = local.nat_subnet_ids[count.index]   # picks correct public subnet

  tags = {
    Name = var.single_nat_gateway ? "${var.project_name}-nat-gw" : "${var.project_name}-nat-gw-${var.region_azs[count.index]}"
  }

  depends_on = [aws_internet_gateway.public_igw]
}