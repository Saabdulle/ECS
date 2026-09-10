variable "project_name" {
  description = "The name of the project."
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC where the RabbitMQ instance will be deployed."
  type        = string
}
variable "rabbitmq_username" {
  description = "The username for the RabbitMQ instance."
  type        = string
}
variable "rabbitmq_password" {
  description = "The password for the RabbitMQ instance."
  type        = string
  sensitive   = true
}
variable "aws_region" {
  description = "The AWS region where the resources will be deployed."
  type        = string
}
variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster."
  type        = string
}
variable "ecs_execution_role_arn" {
  description = "The ARN of the ECS execution role."
  type        = string
}
variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role."
  type        = string
}
variable "ecs_security_group_id" {
  description = "The ID of the security group for the ECS cluster."
  type        = string
}
variable "private_subnet_ids" {
  description = "A list of private subnet IDs where the RabbitMQ instance will be deployed."
  type        = list(string)
}
variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for ECS tasks."
  type        = string
}