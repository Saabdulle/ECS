variable "aws_region" {
  description = "Local AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "Local AWS profile"
  type        = string
  default     = "plane-ecs"
}
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ecs-plane"
}