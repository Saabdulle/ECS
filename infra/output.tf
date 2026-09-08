output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = module.vpc.private_route_table_id
}
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the ALB"
  value       = module.alb.alb_zone_id
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = module.alb.alb_security_group_id
}

output "web_target_group_arn" {
  value = module.alb.web_target_group_arn
}

output "admin_target_group_arn" {
  value = module.alb.admin_target_group_arn
}

output "space_target_group_arn" {
  value = module.alb.space_target_group_arn
}

output "api_target_group_arn" {
  value = module.alb.api_target_group_arn
}

output "live_target_group_arn" {
  value = module.alb.live_target_group_arn
}