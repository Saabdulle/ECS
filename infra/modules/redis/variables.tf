variable "project_name" {
  description = "The name of the project."
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be deployed."
  type        = string
}
variable "private_subnet_ids" {
  description = "A list of private subnet IDs where the RDS instance will be deployed."
  type        = list(string)
}
variable "ecs_security_group_id" {
  description = "The ID of the security group for ECS tasks that need to access the RDS instance."
  type        = string
}