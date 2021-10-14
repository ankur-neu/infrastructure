output "vpc_id" {
  value = aws_vpc.vpc_infra.id
}

output "vpc_gw_id" {
  value = aws_internet_gateway.infra_gw.id
}

output "vpc_subnet_id" {
  value = [for sub in aws_subnet.subnet_infra : sub.id]
}
