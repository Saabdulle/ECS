output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.plane_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnets IDs"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "Private subnets IDs"
  value       = aws_subnet.private_subnet[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.plane_igw.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.plane_nat.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.plane_public_rt.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.plane_private_rt.id
}