output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.plane_ecs_cluster.id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.plane_ecs_cluster.name
}

output "ecs_security_group_id" {
  description = "Security group ID used by ECS tasks"
  value       = aws_security_group.ecs_sg.id
}

output "web_task_definition_arn" {
  description = "Web task definition ARN"
  value       = aws_ecs_task_definition.web.arn
}

output "web_service_name" {
  description = "Web ECS service name"
  value       = aws_ecs_service.web.name
}
output "execution_role_arn" {
  description = "ECS execution role ARN"
  value       = aws_iam_role.ecs_execution_role.arn
}
output "task_role_arn" {
  description = "ECS task role ARN"
  value       = aws_iam_role.ecs_task_role.arn
}
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for ECS tasks"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}