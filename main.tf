locals {
  enable_dns_hostnames = true
  enable_dns_support   = true
  // subnet_az_cidr = {
  //   "us-east-1a" = "10.0.2.0/24",
  //   "us-east-1b" = "10.0.3.0/24",
  //   "us-east-1c" = "10.0.4.0/24",
  // }
}

resource "aws_vpc" "vpc_infra" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_hostnames             = local.enable_dns_hostnames
  enable_dns_support               = true
  enable_classiclink_dns_support   = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name        = "vpc_infra"
    description = "vpc for infrastructue"
  }
}

resource "aws_subnet" "subnet_infra" {
  depends_on = [aws_vpc.vpc_infra]

  for_each = var.subnets

  // for_each = {for sub in var.subnets}

  cidr_block              = each.value.cidr
  vpc_id                  = aws_vpc.vpc_infra.id
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
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
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infra_gw.id
  }

  tags = {
    Name        = "infra_route_table"
    description = "route table for infrastructue"
  }
}