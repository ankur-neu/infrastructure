
resource "aws_vpc" "vpc_infra" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_hostnames             = var.vpc_enable_dns_hostnames
  enable_dns_support               = var.vpc_enable_dns_support
  enable_classiclink_dns_support   = var.vpc_enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.vpc_assign_generated_ipv6_cidr_block

  tags = {
    Name        = "vpc_infra"
    description = "vpc for infrastructue"
  }
}

resource "aws_subnet" "subnet_infra" {
  depends_on = [aws_vpc.vpc_infra]

  for_each = var.subnets

  cidr_block              = each.value.cidr
  vpc_id                  = aws_vpc.vpc_infra.id
  availability_zone       = each.value.az
  map_public_ip_on_launch = var.aws_subnet_map_public_ip_on_launch
  tags = {
    Name        = "subnet_infra_${each.value.count}"
    description = "subnet for infrastructue"
  }
}


resource "aws_internet_gateway" "infra_gw" {
  depends_on = [aws_vpc.vpc_infra]
  vpc_id     = aws_vpc.vpc_infra.id

  tags = {
    Name        = "vpc_infra_gw"
    description = "gateway for infrastructue"
  }
}

resource "aws_route_table" "infra_route" {
  depends_on = [aws_internet_gateway.infra_gw]
  vpc_id     = aws_vpc.vpc_infra.id

  route {
    cidr_block = var.route_table_cidr
    gateway_id = aws_internet_gateway.infra_gw.id
  }

  tags = {
    Name        = "infra_route_table"
    description = "route table for infrastructue"
  }
}

resource "aws_route_table_association" "anan" {
  depends_on     = [aws_route_table.infra_route, aws_subnet.subnet_infra]
  for_each       = aws_subnet.subnet_infra
  subnet_id      = each.value.id
  route_table_id = aws_route_table.infra_route.id
}