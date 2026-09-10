variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ecs_task_role_name" {
  description = "Name of the ECS task IAM role"
  type        = string
}