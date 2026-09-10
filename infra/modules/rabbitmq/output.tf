output "rabbitmq_service_name" {
  value = aws_ecs_service.rabbitmq.name
}

output "rabbitmq_security_group_id" {
  value = aws_security_group.rabbitmq_sg.id
}

output "rabbitmq_task_definition_arn" {
  value = aws_ecs_task_definition.rabbitmq.arn
}