output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.plane_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.plane_alb.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the ALB"
  value       = aws_lb.plane_alb.zone_id
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.plane_sg.id
}

output "web_target_group_arn" {
  description = "ARN of the web target group"
  value       = aws_lb_target_group.plane_web_tg.arn
}

output "admin_target_group_arn" {
  description = "ARN of the admin target group"
  value       = aws_lb_target_group.plane_admin_tg.arn
}

output "space_target_group_arn" {
  description = "ARN of the space target group"
  value       = aws_lb_target_group.plane_space_tg.arn
}

output "api_target_group_arn" {
  description = "ARN of the API target group"
  value       = aws_lb_target_group.plane_api_tg.arn
}

output "live_target_group_arn" {
  description = "ARN of the live target group"
  value       = aws_lb_target_group.plane_live_tg.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.plane_http_listener.arn
}

output "admin_rule_arn" {
  description = "ARN of the admin listener rule"
  value       = aws_lb_listener_rule.plane_admin_rule.arn
}

output "space_rule_arn" {
  description = "ARN of the space listener rule"
  value       = aws_lb_listener_rule.plane_space_rule.arn
}

output "api_rule_arn" {
  description = "ARN of the API listener rule"
  value       = aws_lb_listener_rule.plane_api_rule.arn
}

output "auth_rule_arn" {
  description = "ARN of the auth listener rule"
  value       = aws_lb_listener_rule.plane_auth_rule.arn
}

output "live_rule_arn" {
  description = "ARN of the live listener rule"
  value       = aws_lb_listener_rule.plane_live_rule.arn
}